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
module DTK::Client
  class InteractiveWizard
    require 'readline'

    class << self
      def resolve_missing_params(param_list, additional_message = nil)
        begin
          user_provided_params, checkup_hash = [], {}

          OsUtil.print("\nPlease fill in missing data.")
          param_list.each do |param_info|
            description =
              if param_info['display_name'] =~ Regexp.new(param_info['description'])
                param_info['display_name']
              else
                "#{param_info['display_name']} (#{param_info['description']})"
              end
            datatype_info = (param_info['datatype'] ? OsUtil.colorize(" [#{param_info['datatype'].upcase}]", :yellow) : '')
            string_identifier = OsUtil.colorize(description, :green) + datatype_info

            puts "Please enter #{string_identifier}:"
            while line = Readline.readline(": ", true)
              id = param_info['id']
              user_provided_params << {:id => id, :value => line, :display_name => param_info['display_name']}
              checkup_hash[id] = {:value => line, :description => description}
              break
            end

          end

          # pp print for provided parameters
          pretty_print_provided_user_info(checkup_hash)

          # make sure this is satisfactory
          while line = Readline.readline("Is provided information ok? (yes|no) ", true)
            # start all over again
            return resolve_missing_params(param_list) if 'no'.eql? line
            # continue with the code
            break if 'yes'.eql? line
          end

         rescue Interrupt => e
          raise Error::Usage, "You have decided to skip correction wizard.#{additional_message}"
        end

        return user_provided_params
      end
      
      def interactive_user_input(wizard_dsl, recursion_call = false)
        results = {}
        wizard_dsl = [wizard_dsl].flatten
        begin
          wizard_dsl.each do |meta_input|
            input_name = meta_input.keys.first
            display_name = input_name.to_s.gsub(/_/,' ').capitalize
            metadata = meta_input.values.first

            # default values
            output = display_name
            validation = metadata[:validation]
            is_password = false
            is_required = metadata[:requried]

            case metadata[:type]
              when nil
              when :email
                validation = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
              when :question
                output = "#{metadata[:question]}"
                validation = metadata[:validation]
              when :password
                is_password = true
                is_required = true
              when :repeat_password
                is_password = true
                is_required = true
                validation  = /^#{results[:password]}$/
              when :selection
                options = ""
                display_field = metadata[:display_field]
                metadata[:options].each_with_index do |o,i|
                  if display_field
                    options += "\t#{i+1}. #{o[display_field]}\n"
                  else
                    options += "\t#{i+1}. #{o}\n"
                  end
                end
                options += OsUtil.colorize("\t0. Skip\n", :yellow) if metadata[:skip_option]
                output = "Select '#{display_name}': \n\n #{options} \n "
                validation_range_start = metadata[:skip_option] ? 0 : 1
                validation = (validation_range_start..metadata[:options].size).to_a
              when :group
                # recursion call to populate second level of hash params
                puts " Enter '#{display_name}': "
                results[input_name] = self.interactive_user_input(metadata[:options], true)
                next
            end

            input = text_input(output, is_required, validation, is_password)

            if metadata[:required_options] && !metadata[:required_options].include?(input)
              # case where we have to give explicit permission, if answer is not affirmative
              # we terminate rest of the wizard
              OsUtil.print(" #{metadata[:explanation]}", :red)
              return nil
            end

            # post processing
            if metadata[:type] == :selection
              input = input.to_i == 0 ? nil : metadata[:options][input.to_i - 1]
            end

            results[input_name] = input
          end

          return results
        rescue Interrupt => e
          puts
          raise DtkValidationError, "Exiting the wizard ..."
        end
      end
      
      def text_input(output, is_required = false, validation_regex = nil, is_password = false)
        while line = ask("#{output}: ") { |q| q.echo = !is_password }
          if is_required && line.strip.empty?
            puts OsUtil.colorize("Field '#{output}' is required field. ", :red)
            next
          end

          if validation_regex && !validation_regex.match(line)
            puts OsUtil.colorize("Input is not valid, please enter it again. ", :red)
            next
          end

          return line
        end
      end

      private

      def pretty_print_provided_user_info(user_information)
        OsUtil.print('--------------------------------- DATA ---------------------------------')

        user_information.each do |key,info|
          description = info[:description]
          value = info[:value]
          printf "%48s : %s\n", OsUtil.colorize(description, :green), OsUtil.colorize(value, :yellow)
        end

        OsUtil.print('------------------------------------------------------------------------')
      end

    end

  end
end

