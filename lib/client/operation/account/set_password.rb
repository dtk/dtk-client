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
  class Operation::Account
    class SetPassword < self
      def self.execute(args = Args.new)
        old_pass_prompt, old_pass, new_pass_prompt, confirm_pass_prompt = nil
        cred_file = Configurator::CRED_FILE
        old_pass = DTK::Client::Configurator.parse_key_value_file(cred_file)[:password]
        username = DTK::Client::Configurator.parse_key_value_file(cred_file)[:username]

        if old_pass.nil?
          OsUtil.print("Unable to retrieve your current password!", :yellow)
          return
        end

        3.times do
          old_pass_prompt = DTK::Client::Console.password_prompt("Enter old password: ")

          break if (old_pass.eql?(old_pass_prompt) || old_pass_prompt.nil?)
          OsUtil.print("Incorrect old password!", :yellow)
        end
        return unless old_pass.eql?(old_pass_prompt)

        new_pass_prompt = DTK::Client::Console.password_prompt("Enter new password: ")
        return if new_pass_prompt.nil?
        confirm_pass_prompt = DTK::Client::Console.password_prompt("Confirm new password: ")

        if new_pass_prompt.eql?(confirm_pass_prompt)
          post_body = {:new_password => new_pass_prompt}
          response = rest_post("#{RoutePrefix}/set_password", post_body)
          return response unless response.ok?

          Configurator.regenerate_conf_file(cred_file, [['username', "#{username.to_s}"], ['password', "#{new_pass_prompt.to_s}"]], '')
          OsUtil.print("Password changed successfully!", :yellow)
        else
          OsUtil.print("Entered passwords don't match!", :yellow)
          return
        end
      end    
          
      end
    end
  end
