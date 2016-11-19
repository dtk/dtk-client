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

          # will create different classes for different catalog types when we add support for them
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

        # unless version is explicitly provided, use latest version instead of master
        unless @version
          @version = module_info.required(:latest_version)
        end

        git_repo_args = {
          :repo_dir      => target_repo_dir,
          :repo_url      => module_info.required(:remote_repo_url),
          :remote_branch => (@version && !@version.eql?('master')) ? "v#{@version}" : 'master'
        }
        ClientModuleDir::GitRepo.create_add_remote_and_pull(git_repo_args)

        module_content_hash = ContentGenerator.new(target_repo_dir, @module_ref, @version).generate_module_content

        # delete old files
        Operation::ClientModuleDir.delete_directory_content(target_repo_dir)

        # generate dtk.module.yaml file from parsed assemblies and module_refs
        Operation::ClientModuleDir.create_file_with_content("#{target_repo_dir}/dtk.module.yaml", self.class.hash_to_yaml(module_content_hash))
        {:target_repo_dir => target_repo_dir}
      end
      
      private

      def initialize(catalog, module_ref, directory_path, version)
        @catalog        = catalog
        @module_ref     = module_ref
        @directory_path = directory_path
        @version        = version
      end
    end
  end
end


