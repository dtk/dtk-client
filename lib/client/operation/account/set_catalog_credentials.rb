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
    class SetCatalogCredentials < self
      def self.execute(args = Args.new)
        creds = DTK::Client::Configurator.enter_catalog_credentials()

        post_body = { :username => creds[:username], :password => creds[:password], :validate => true }
        response = rest_post("#{RoutePrefix}/set_catalog_credentials", post_body)
        return response unless response.ok?

        OsUtil.print("Your catalog credentials have been set!", :yellow)  
      end
    end
  end
end
