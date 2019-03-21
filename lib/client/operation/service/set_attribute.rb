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
  class Operation::Service
    class SetAttribute < self
      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          service_instance = args.required(:service_instance)
          attribute_name   = args[:attribute_name]
          attribute_value  = args[:attribute_value]
          encrypt = args[:encrypt]
          if encrypt
            hash = {
              :name                => attribute_name.split('/').last 
            }
            set_attribute = rest_get "#{BaseRoute}/#{service_instance}/get_attribute", QueryStringHash.new(hash)

            hash = {
              :name                => "encryption_public_key"  
            }
            public_key_attribute = rest_get "#{BaseRoute}/#{service_instance}/get_attribute", QueryStringHash.new(hash)

            if public_key_attribute.data.empty? || set_attribute.data["component_component_id"] != public_key_attribute.data["component_component_id"]
              raise Error::Usage, "There is no encryption_public_key attribute in this component, or its' value is not set."
            end
            public_key = public_key_attribute.data["value_asserted"] || public_key_attribute.data["value_derived"]
            attribute_value = DTK::Client::SecurityUtil.encrypt(public_key, attribute_value) 
          end
          query_string_hash = QueryStringHash.new(
            :pattern?  => attribute_name,
            :value?    => attribute_value
          )
          response = rest_post("#{BaseRoute}/#{service_instance}/set_attribute", query_string_hash)

          if repo_updated = response.data["repo_updated"] 
            repo_info_args = Args.new(
             :service_instance => service_instance,
             :branch           => response.required(:branch, :name),
             :repo_url         => response.required(:repo, :url),
             :service_instance_dir => args[:service_instance_dir]
           )
 
           ClientModuleDir::GitRepo.pull_from_service_repo(repo_info_args)
         end
         nil
        end
      end
    end
  end
end
