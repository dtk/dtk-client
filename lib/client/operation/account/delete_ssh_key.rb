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
    class DeleteSshKey < self
      def self.execute(args = Args.new)
        name = args[:name]
        # unless args[:force]
        #   is_go = Console.confirmation_prompt("Are you sure you want to delete SSH key '#{name}'"+"?")
        #   return nil unless is_go
        # end
        post_body = {
          :username => name
        }
        response = rest_post("#{RoutePrefix}/delete_ssh_key", post_body)
        return response unless response.ok?

        if response.ok? && response.data(:repoman_registration_error)
          OsUtil.print("Warning: We were not able to unregister your key with remote catalog! #{response.data(:repoman_registration_error)}", :yellow)
        end

        OsUtil.print("SSH key '#{name}' removed successfully!", :yellow)
      end
    end
  end
end
