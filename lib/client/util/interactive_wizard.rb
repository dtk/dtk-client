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

    PP_LINE_HEAD  = '--------------------------------- DATA ---------------------------------'
    PP_LINE       = '------------------------------------------------------------------------'
    INVALID_INPUT = OsUtil.colorize(" Input is not valid. ", :yellow)

    class << self
      def resolve_missing_params(param_list, additional_message = nil)
        begin
          user_provided_params, checkup_hash = [], {}

          puts "\nPlease fill in missing data.\n"
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
          fail Error::Usage, "You have decided to skip correction wizard.#{additional_message}"
        end

        return user_provided_params
      end

      private

      def pretty_print_provided_user_info(user_information)
        puts PP_LINE_HEAD
        user_information.each do |key,info|
          description = info[:description]
          value = info[:value]
          printf "%48s : %s\n", OsUtil.colorize(description, :green), OsUtil.colorize(value, :yellow)
        end
        puts PP_LINE
        puts
      end

    end

  end
end

