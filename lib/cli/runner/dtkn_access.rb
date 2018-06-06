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
module DTK::Client; module CLI
  class Runner
    module DTKNAccess
      include ::DTK::Client
      # check if .add_direct_access file exists, if not then add direct access and create .add_direct_access file
      def self.resolve_direct_access(config_existed)
        params = Configurator.check_direct_access
        return if params[:username_exists]
        
        OsUtil.print_info('Processing ...') if config_existed
        # check to see if catalog credentials are set
        # conn = Session.get_connection
        # response = conn.post 'account/check_catalog_credentials'
        
        # # set catalog credentails
        # if response.ok? && !response.data(:catalog_credentials_set)
        #   # setting up catalog credentials
        #   catalog_creds = Configurator.ask_catalog_credentials
        #   unless catalog_creds.empty?
        #     post_body = {
        #       :username => catalog_creds[:username],
        #       :password => catalog_creds[:password],
        #       :validate => true
        #     }
        #     response = conn.post 'account/set_catalog_credentials', post_body
        #     unless response.ok?
        #       error_message = response.error_message.gsub(/\.[ ]*$/,'')
        #       OsUtil.print_error("#{error_message}. You will have to set catalog credentials manually ('dtk account set-catalog-credentials').")
        #     end
        #   end
        # end

        add_key_opts = {
          :first_registration => true, 
          :name => "#{Session.connection_username}-client"
        }
        response = Operation::Account.add_key(params[:ssh_key_path], add_key_opts)
        matched_pub_key = response.data(:matched_pub_key)
        matched_username = response.data(:matched_username)
        
        if !response.ok?
          error_message = response.error_message.gsub(/\.[ ]*$/,'')
          OsUtil.print_warning("We were not able to add access for current user. #{error_message}. In order to properly use dtk-shell you will have to add access manually ('dtk account add-ssh-key').\n")
        elsif matched_pub_key
          # message will be displayed by add key # TODO: Refactor this flow
          OsUtil.print_warning("Provided SSH PUB key has already been added.")
          Configurator.add_current_user_to_direct_access
        elsif matched_username
          OsUtil.print_warning("User with provided name already exists.")
        else
          # commented out because 'add_key' method called above will also print the same message
          # OsUtil.print_info("Your SSH PUB key has been successfully added.")
          Configurator.add_current_user_to_direct_access
        end
        response
      end
    end
  end
end; end
