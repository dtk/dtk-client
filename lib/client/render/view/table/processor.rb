#
# Copyright (C) 2010-2016 dtk contributors
#
# This file is part of the dtk project.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
require 'hirb'
require 'ostruct'
require 'colorize'
require 'rest_client'
require 'json'

# we override String here to give power to our mutators defined in TableDefintions
class String
  def get_date
    DateTime.parse(self).strftime('%H:%M:%S %d/%m/%y') unless self.nil?
  end
end

module DTK::Client
  class Render::Table
    class Processor
      include Hirb::Console

      # opts can have keys
      #  :print_error_table - Boolean (default: false)
      def self.render(data, table_definition, opts = {})
        new(table_definition).render(data, opts)
      end

      def initialize(table_definition)
        @order_definition  = table_definition.order_definition
        @table_mapping     = table_definition.mapping
        @evaluated_data    = []
        @error_data        = []
        @action_data       = []
        @footnote          = nil
        @failed_components = []
      end
      private :initialize


      def render(data, opts = {})
        evaluate(data, opts)
        print
      end

      private

      def evaluate(data, opts = {})
        # very important since rest of the code expect array to be used
        data = [data] unless data.kind_of?(Array)

        print_error_table = opts[:print_error_table]
        @footnote         = opts[:footnote]


        data.each do |data_element|
          next if data_element['dtk_client_hidden']
          structured_element = to_ostruct(data_element)
        
          # we use array of OpenStruct to hold our evaluated values
          evaluated_element = OpenStruct.new
          error_element     = OpenStruct.new
          
          # based on mapping we set key = eval(value)
          @table_mapping.each do |k, v|
            begin
              if print_error_table && k.include?('error')
                error_message = value_of(structured_element, v)
                if failed_component = value_of(structured_element, 'failed_component')
                  @failed_components << "- #{failed_component.gsub('__','::')}"
                end
                
                if  error_message.include?("Deadline Exceeded")
                  error_message = "Byebug session timeout, please run 'dtk service converge' again."
                end

                # due to problems with space we have special way of handling error columns
                # in such a way that those error will be specially printed later on
                server_error = nil
              
                # here we see if there was an error if not we will skip this
                # if so we add it to @error_data
                if error_message.empty?
                  # no error message just add it as regular element
                  evaluated_element.send("#{k}=",value_of(structured_element, v))
                else
                  error_index = ""
                  error_type = value_of(structured_element,'errors.dtk_type') || ""
          
                  val = value_of(structured_element,'dtk_type')||''
                  # extract e.g. 3.1.1.1 from '3.1.1.1 action' etc.
                  error_index = "[ #{val.scan( /\d+[,.]?\d?[,.]?\d?[,.]?\d?[,.]?\d?/ ).first} ]"
                  
                  # original table takes that index
                  evaluated_element.send("#{k}=", error_index)
                  # we set new error element
                  set_error_element!(error_element, error_index, error_type, error_message)
                  
                  # add it with other
                  @error_data << error_element
                end
              else
                evaluated_element.send("#{k}=", value_of(structured_element, v))
                # eval "evaluated_element.#{k}=structured_element.#{v}"
              end
            rescue NoMethodError => e
              unless e.message.include? "nil:NilClass"
                # when chaining comands there are situations where more complex strcture
                # e.g. external_ref.region will not be there. So we are handling that case
                # make sure when in development to disable this TODO: better solution needed
                raise Error, "Error with missing metadata occurred. There is a mistake in table metadata or unexpected data presented to table view."
              end
            end
          end
          
          @order_definition.delete('errors')
          
          @evaluated_data << evaluated_element
        end
      end
      
      def set_error_element!(error_element, error_index, error_type, error_message)
        error_element.id = error_index
        case error_type
        when 'user_error'
          error_element.message = "[USER ERROR] #{error_message}"
        when "test_error"
          error_element.message = "[TEST ERROR] #{error_message}"
        else
          error_element.message = "[SERVER ERROR] #{error_message}"
        end
      end
      
      def print
        filter_remove_underscore = Proc.new { |header| header.gsub('_',' ').upcase }
        # hirb print out of our evaluated data in order defined
        # Available options can be viewed here: http://tagaholic.me/hirb/doc/classes/Hirb/Helpers/Table.html#M000008
        table(@evaluated_data,{:fields => @order_definition,:escape_special_chars => true, :resize => false, :vertical => false, :header_filter => filter_remove_underscore })
        
        # in case there were error we print those errors
        unless @error_data.empty?
          printf "\nERRORS: \n\n"
          @error_data.each do |error_row|
            printf "%15s %s\n", error_row.id.colorize(:yellow), error_row.message.colorize(:red)
          end
        end
        
        unless @action_data.empty?
          printf " \n"
          #table(@error_data,{:fields => [ :id, :message ]})
          printed = []
          @action_data.each do |action_row|
            message = action_row.message
            printf "%15s %s\n", "INFO:".colorize(:yellow), message.colorize(:yellow) unless printed.include?(message)
            printed << message
          end
        end

        if @footnote
          printf " \n"
          printf "%15s %s\n", "INFO:".colorize(:yellow), @footnote.colorize(:yellow)
        end

        unless @failed_components.empty?
          printf " \n"
          printf "%15s %s\n", "INFO:".colorize(:yellow), "Following components could not be deleted:\n\t#{@failed_components.uniq.join(', ').colorize(:yellow)}\nYou can use the command 'dtk service eject COMPONENT' to remove any of these component(s) from dtk management. However, when using the eject command,  you will need to manually remove the actual resources, such as an ec2 instance.".colorize(:yellow)
        end
      end
      
      
      def to_ostruct(data)
        result = data.inject({}) do |res, (k, v)|
          k = safe_name(k)
          case v
          when Hash
            res.store(k, to_ostruct(v))
            res
          when Array
            res.store(k, v.each { |el| Hash === el ? to_ostruct(el) : el })
            res
          else
            res.store(k,v)
            res
          end
        end
        
        OpenStruct.new(result)
      end
      
      def safe_name(identifier)
        (identifier == 'id' || identifier  == 'type') ? "dtk_#{identifier}" : identifier
      end
      
      def filter_remove_underscore(_field)
        nil
      end
      
      # based on string sequence in mapped_command we are executing list of commands to follow
      # so for value of "foo.bar.split('.').last" we will get 4 commands that will
      # sequentaly be executed using values from previus results
      def value_of(open_struct_object, mapped_command)
        # split string by '.' delimiter keeping in mind to split when words only
        commands = mapped_command.split(/\.(?=\w)/)
        
        value = open_struct_object
        commands.each do |command|
          value = evaluate_command(value, command)
        end
        value
      end
      
      def evaluate_command(value, command)
        case
        when command.include?('map{')
          matched_data = command.match(/\['(.+)'\]/)
          
          my_lambda = lambda{|_x| _x.map{|r|r["#{matched_data[1]}"]||[]}}
          value = my_lambda.call(value)
          
          raise Error, "There is a mistake in table metadata: #{command.inspect}" if value.nil?
        when command.include?('(')
          # matches command and params e.g. split('.') => [1] split, [2] '.'
          matched_data = command.match(/(.+)\((.+)\)/)
          command, params = matched_data[1], matched_data[2]
          value = value.send(command,params)
        when command.include?('[')
          # matches command such as first['foo']
          matched_data    = command.match(/(.+)\[(.+)\]/)
          command, params =  matched_data[1],matched_data[2]
          
          value = evaluate_command(value,command)
          value = value.send('[]',params)
        when command.start_with?("list_")
          matched_data = command.match(/list_(.+)/)
          
          my_lambda = lambda{|_x| _x.map{|r|r["#{matched_data[1]}"]||[]}}
          value = my_lambda.call(value)
          
          raise Error, "There is a mistake in table metadata: #{command.inspect}" if value.nil?
        when command.start_with?("count_")
          matched_data = command.match(/count_(.+)/)
          
          my_lambda = lambda{|_x| _x.map{|r|r["#{matched_data[1]}"]||[]}.flatten.size}
          value = my_lambda.call(value)
          
          raise Error, "There is a mistake in table metadata: #{command.inspect}" if value.nil?
        else
          value = value.send(command)
        end
        value
      end
    end
  end
end

