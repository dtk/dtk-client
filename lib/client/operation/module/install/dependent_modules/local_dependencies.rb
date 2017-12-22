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
    class LocalDependencies < Operation::Module
      include Install::Mixin
      BaseRoute  = "modules"

      def initialize(module_ref, prompt_helper, print_helper)
        @module_ref    = module_ref
        @prompt_helper = prompt_helper
        @print_helper  = print_helper.set_module_ref!(module_ref)
      end
      private :initialize

      def self.install_or_pull?(server_response, prompt_helper, print_helper)
        if dependencies = (server_response.data(:dependencies)||{})['required_modules']
          dependencies.each do |dep|
            unless Install::DependentModules.resolved.include?("#{dep['namespace']}:#{dep['name']}")
              Install::DependentModules.add_to_resolved("#{dep['namespace']}:#{dep['name']}")
              dep_module_ref = Install::DependentModules.create_module_ref(dep, opts = {})
              if dep_ref_info = module_version_exists?(dep_module_ref, :remote_info => true, :rsa_pub_key => SSHUtil.rsa_pub_key_content)
                new_print_helper = Install::PrintHelper.new(:module_ref => dep_module_ref, :source => :remote)
                if dep_ref_info.data(:has_remote) && !prompt_helper.update_none
                  ComponentModule.install_or_pull?(dep_module_ref, prompt_helper, new_print_helper) unless dep_module_ref.is_base_module?
                else
                  new_print_helper.print_using_installed_dependent_module
                end
              end
            end
          end
        end
      end
    end
  end
end; end


