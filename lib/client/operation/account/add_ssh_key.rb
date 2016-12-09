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
    class AddSshKey < self
      def self.execute(args = Args.new)
        path_to_key = args[:directory_path] unless args[:directory_path].nil?
        path_to_key ||= SSHUtil.default_rsa_pub_key_path()

        opts = {
          :name => args[:name]
        }

        response, matched, matched_username = Account.add_key(path_to_key, opts)

        if matched
          OsUtil.print("Provided SSH pub key has already been added.", :yellow)
        elsif matched_username
          OsUtil.print("User ('#{matched_username}') already exists.", :yellow)
        else
          Configurator.add_current_user_to_direct_access() if response.ok?
        end

        if response.ok? && response.data(:repoman_registration_error)
          OsUtil.print("Warning: We were not able to register your key with remote catalog! #{response.data(:repoman_registration_error)}", :yellow)
        end

        response.ok? ? nil : response
      end
      end
    end
  end
