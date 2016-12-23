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
      attr_reader :version, :module_ref, :target_repo_dir
      def initialize(catalog, module_ref, directory_path, version)
        @catalog          = catalog
        @module_ref       = module_ref
        @directory_path   = directory_path
        @target_repo_dir  = ClientModuleDir.create_module_dir_from_path(directory_path || OsUtil.current_dir)
        @version          = version # if nil wil be dynamically updated along with version attribute of @module_ref
      end
      private :initialize

      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          module_ref     = args.required(:module_ref)
          version        = args[:version]
          directory_path = args[:directory_path]

          # will create different classes for different catalog types when we add support for them
          new('dtkn', module_ref, directory_path, version).install_from_catalog
        end
      end
      
      def install_from_catalog

        query_string_hash = QueryStringHash.new(
          :module_name => @module_ref.module_name,
          :namespace   => @module_ref.namespace,
          :rsa_pub_key => SSHUtil.rsa_pub_key_content,
          :version?    => @version
        )

        remote_module_info = rest_get "#{BaseRoute}/remote_module_info", query_string_hash

        unless @version 
          @version = remote_module_info.required(:version)
          @module_ref.version = @version
        end

        if module_version_exists?(@module_ref, :type => :common_module)
          raise Error::Usage, "Module '#{@module_ref.print_form}' exists already"
        end

        create_repo_opts = { :repo_dir => @target_repo_dir, :commit_msg => "DTK client initialize" }
        Operation::ClientModuleDir::GitRepo.create_repo_with_empty_commit(create_repo_opts)
        LoadSource.fetch_transform_and_merge(remote_module_info, self)

        {:target_repo_dir => @target_repo_dir}
      end

    end
  end
end


