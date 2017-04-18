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
module DTK::Client; class Operation::Module
  class Install::DependentModules
    class RemoteDependencies < Operation::Module
      include Install::Mixin
      BaseRoute  = "modules"

      def initialize(module_ref, prompt_helper, print_helper)
        @module_ref    = module_ref
        @prompt_helper = prompt_helper
        @print_helper  = print_helper.set_module_ref!(module_ref)
      end
      private :initialize

      def self.install_or_pull?(component_module_ref, prompt_helper, print_helper)
        remote_response = nil
        begin
          hash = {
            :module_name => component_module_ref.module_name,
            :namespace   => component_module_ref.namespace,
            :rsa_pub_key => SSHUtil.rsa_pub_key_content,
            :version?    => component_module_ref.version
          }
          remote_response = rest_get "#{BaseRoute}/module_dependencies", QueryStringHash.new(hash)
        rescue Error::ServerNotOkResponse => e
          # temp fix for issue when dependent module is imported from puppet forge
          if errors = e.response && e.response['errors']
            remote_response = nil if errors.first.include?('not found')
          else
            raise e
          end
        end

        if remote_required = remote_response.data(:required_modules)
          remote_required.each do |req_module|
            unless Install::DependentModules.resolved.include?("#{req_module['namespace']}:#{req_module['name']}")
              Install::DependentModules.add_to_resolved("#{req_module['namespace']}:#{req_module['name']}")
              req_ref = Install::DependentModules.create_module_ref(req_module)
              new_print_helper = Install::PrintHelper.new(:module_ref => req_ref, :source => :remote)
              if prompt_helper.pull_module_update?(new_print_helper)
                ComponentModule.install_or_pull_new?(req_ref, prompt_helper, new_print_helper) unless req_ref.is_base_module?
              end
            end
          end
        end
      end
    end
  end
end; end


