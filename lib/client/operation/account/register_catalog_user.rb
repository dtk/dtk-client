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
    class RegisterCatalogUser < self
      def self.execute(args = Args.new)
        body_params = DTK::Client::InteractiveWizard.interactive_user_input([
       {:username => { :required => true} },
       {:password => { :type => :password }},
       {:repeat_password => { :type => :repeat_password }},
       {:email => { :type => :email, :required => true }},
       {:first_name => {}},
       {:last_name => {}}
      ])
      OsUtil.print("Creating account please wait ...", :white)

      response = rest_post("#{RoutePrefix}/register_catalog_account", body_params) 

      if response.ok?
        OsUtil.print("You have successfully created catalog account!", :green)
        if DTK::Client::Console.prompt_yes_no("Do you want to make this account active?")
          post_body =  { :username => body_params[:username], :password => body_params[:password], :validate => true }
          response = rest_post("#{RoutePrefix}/set_catalog_credentials", post_body)
          OsUtil.print("Catalog user '#{body_params[:username]}' is currently active user!", :green)
        end
      else
        return response
      end

      nil
      end
    end
  end
end
