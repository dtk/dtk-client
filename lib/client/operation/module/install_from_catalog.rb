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
  class Operation::Module
    class InstallFromCatalog < self
      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          module_ref     = args.required(:module_ref)
          version        = args[:version]
          directory_path = args[:directory_path]

          # will create different classes for different catalog taypes when we add support for them
          new('dtkn', module_ref, directory_path, version).install
        end
      end
      
      def install
        if module_exists?(@module_ref, :type => :common_module)
          raise Error::Usage, "Module #{@module_ref.print_form} exists already"
        end

        target_repo_dir = ClientModuleDir.create_module_dir_from_path(@directory_path || OsUtil.current_dir)

        query_string_hash = QueryStringHash.new(
          :module_name => @module_ref.module_name,
          :namespace   => @module_ref.namespace,
          :rsa_pub_key => SSHUtil.rsa_pub_key_content,
          :version?    => @version
        )
        module_info = rest_get "#{BaseRoute}/remote_module_info", query_string_hash

        git_repo_args = {
          :repo_dir      => target_repo_dir,
          :repo_url      => module_info.required(:remote_repo_url),
          :remote_branch => @version ? "v#{@version}" : 'master'
        }
        ClientModuleDir::GitRepo.create_add_remote_and_pull(git_repo_args)

        # TODO: Add dtk.module.yaml file generation from assemblies and module_refs
      end
      
      private

      def initialize(catalog, module_ref, directory_path, version)
        @catalog        = catalog
        @module_ref     = module_ref
        @directory_path = directory_path
        @version        = version
      end

      def create_path(namespace, name)

      end
    end
  end
end


