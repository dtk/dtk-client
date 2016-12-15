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
module DTK::Client; class Operation::Module::Install
  class DependentModules
    class InstallComponentModule < Operation::Module
      include DependentModules::Mixin
      BaseRoute  = "modules"

      def initialize(module_ref, prompt_helper, print_helper)
        @module_ref    = module_ref
        @prompt_helper = prompt_helper
        @print_helper  = print_helper.set_module_ref!(module_ref)
      end
      private :initialize

      def self.install?(module_ref, prompt_helper, print_helper)
        new(module_ref, prompt_helper, print_helper).install?
      end
      
      def install?
        if module_installed?
          pull_module_update?
          # find_and_install_component_module_dependency(:skip_if_no_remote => true, indent: "  ")
        else
          install_module
        end
      end

      private

      def module_installed?
        module_exists?(@module_ref, :type => :component_module)
      end

      def pull_module_update?
        return unless @prompt_helper.pull_module_update?(@print_helper)

        # TODO: if locked version than want a print_using_installed_module messgage
        @print_helper.print_pulling_update

        post_body = {
          :module_name => module_name,
          :namespace   => namespace,
          :rsa_pub_key => SSHUtil.rsa_pub_key_content,
          :version?    => version,
          :full_module_name => full_module_name,
          :json_diffs  => ""
        }
        response = rest_post "#{BaseRoute}/update_dependency_from_remote", PostBody.new(post_body)

        if custom_message = response.data[:custom_message]
          OsUtil.print(custom_message)
        elsif (response.data[:diffs].nil? || response.data[:diffs].empty?)
          OsUtil.print("No changes to pull from remote.", :yellow) unless response['errors']
        else
          OsUtil.print("Changes pulled from remote", :green)
        end
      end

      def install_module
        @print_helper.print_install_msg

        post_body = {
          :module_name => module_name,
          :namespace   => namespace,
          :rsa_pub_key => SSHUtil.rsa_pub_key_content,
          :version?    => version
        }

        # unless opts[:skip_dependencies]
        #  find_and_install_component_module_dependency(component_module, opts.merge(:add_newline => true, indent: "  "))
        # end

        response = rest_post "#{BaseRoute}/install_component_module", PostBody.new(post_body)

        clone_args = {
          :module_type => :component_module,
          :repo_url    => response.required(:repo_url),
          :branch      => response.required(:workspace_branch),
          :module_name => response.required(:full_module_name)
        }

        @print_helper.print_done_message
        response
      end

    end
  end
end; end


