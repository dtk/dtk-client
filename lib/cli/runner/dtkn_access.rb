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
module DTK::CLI
  class Runner
    module DTKNAccess
      include ::DTK::Client
      # check if .add_direct_access file exists, if not then add direct access and create .add_direct_access file
      def self.resolve_direct_access(config_exists)
        params = Configurator.check_direct_access
        return if params[:username_exists]
        
        OsUtil.print('Processing ...', :yellow) if config_exists
        # check to see if catalog credentials are set
        conn = Session.get_connection
        response = conn.post 'account/check_catalog_credentials'
        
        # set catalog credentails
        if response.ok? && !response.data['catalog_credentials_set']
          # setting up catalog credentials
          catalog_creds = Configurator.ask_catalog_credentials
          unless catalog_creds.empty?
            response = conn.post 'account/set_catalog_credentials', { :username => catalog_creds[:username], :password => catalog_creds[:password], :validate => true}
            if errors = response['errors']
              OsUtil.print("#{errors.first['message']} You will have to set catalog credentials manually ('dtk account set-catalog-credentials').", :yellow)
            end
          end
        end
        add_key_opts = {
          :first_registration => true, 
          :name => "#{Session.connection_username}-client"
        }
        response, matched_pub_key, matched_username = Execute::Account.add_key(params[:ssh_key_path], add_key_opts)
        
        if !response.ok?
          OsUtil.print("We were not able to add access for current user. #{response.error_message}. In order to properly use dtk-shell you will have to add access manually ('dtk account add-ssh-key').\n", :yellow)
        elsif matched_pub_key
          # message will be displayed by add key # TODO: Refactor this flow
          OsUtil.print("Provided SSH PUB key has already been added.", :yellow)
          Configurator.add_current_user_to_direct_access
        elsif matched_username
          OsUtil.print("User with provided name already exists.", :yellow)
        else
          # commented out because 'add_key' method called above will also print the same message
          # OsUtil.print("Your SSH PUB key has been successfully added.", :yellow)
          Configurator.add_current_user_to_direct_access
        end
        response
      end
    end
  end
end
