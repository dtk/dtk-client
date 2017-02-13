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
    class ComponentModule < Operation::Module
      include Install::Mixin
      BaseRoute  = "modules"

      def initialize(module_ref, prompt_helper, print_helper)
        @module_ref    = module_ref
        @prompt_helper = prompt_helper
        @print_helper  = print_helper.set_module_ref!(module_ref)
      end
      private :initialize

      def self.install_or_pull?(module_ref, prompt_helper, print_helper)
        new(module_ref, prompt_helper, print_helper).install_or_pull?
      end
      
      def install_or_pull?
        if @module_ref.module_installed?(self)
          if @module_ref.is_master_version?
            pull_module_update?
          else
            @print_helper.print_using_installed_dependent_module
          end
        else
          install_module
        end
      end

      def query_if_component_module_is_installed?
        # TODO: :type => :component_module is for legacy; once we get past having legacy can change to :common_module
        module_version_exists?(@module_ref, :type => :component_module)
      end

      private

      def pull_module_update?
        return unless @prompt_helper.pull_module_update?(@print_helper)
        @print_helper.print_continuation_pulling_dependency_update

        post_body = {
          :module_name => module_name,
          :namespace   => namespace,
          :rsa_pub_key => SSHUtil.rsa_pub_key_content,
          :version?    => version,
          :force       => true # TODO: hardwired
        }
        response = rest_post "#{BaseRoute}/pull_component_info_from_remote", PostBody.new(post_body)

        if (response.data(:diffs) || {}).empty?
#          OsUtil.print("No changes to pull from remote.", :yellow) unless response['errors']
          OsUtil.print("No changes to pull from remote.", :yellow) 
        else
          OsUtil.print("Changes pulled from remote", :green)
        end
      end

      def install_module
        @print_helper.print_continuation_installing_dependency

        post_body = {
          :module_name => module_name,
          :namespace   => namespace,
          :rsa_pub_key => SSHUtil.rsa_pub_key_content,
          :version?    => version
        }

        response = rest_post "#{BaseRoute}/install_component_info", PostBody.new(post_body)

        @print_helper.print_done_message
        response
      end

    end
  end
end; end


