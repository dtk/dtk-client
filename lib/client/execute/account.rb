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
  class Execute
    class Account < self
      RoutePrefix = 'account'

      # opts can have keys
      #  :first_registration - Booelan (default: false)
      #  :name - (default: 'dtk-client')
      # returns [response, match, matched_username]
      def self.add_key(path_to_key, opts = {})
        match, matched_username = nil, nil

        unless File.file?(path_to_key)
          raise Error,"[ERROR] No ssh key file found at (#{path_to_key}). Path is wrong or it is necessary to generate the public rsa key (e.g., run `ssh-keygen -t rsa`)."
        end
        
        response, key_exists_already = add_user_access(path_to_key, opts)

        return [response, nil, nil] unless response.ok?

        match = response.data['match']
        matched_username = response.data['matched_username']

        if response && !match
          repo_manager_fingerprint,repo_manager_dns = response.data_ret_and_remove!(:repo_manager_fingerprint,:repo_manager_dns)
          SSHUtil.update_ssh_known_hosts(repo_manager_dns,repo_manager_fingerprint)
          OsUtil.print("SSH key '#{response.data["new_username"]}' added successfully!", :yellow)
        end
        
        [response, match, matched_username]
      end

      private

      # opts can have keys
      #  :first_registration - Booelan (default: false)
      # :name - (default: 'dtk-client')
      def self.add_user_access(path_to_key, opts = {})
        first_registration = opts[:first_registration] || false
        name = opts[:name] || 'dtk-client'

        rsa_pub_key = SSHUtil.read_and_validate_pub_key(path_to_key)
        
        post_body  = { 
          :rsa_pub_key        => rsa_pub_key.chomp,
          :username?          => name && name.chomp,
          :first_registration => first_registration,
        }
        rest_post "#{RoutePrefix}/add_user_direct_access", PostBody.new(post_body)
      end
    end
  end
end


