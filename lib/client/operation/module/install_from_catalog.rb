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
      require_relative('install_from_catalog/base')
      # base needs to go first
      require_relative('install_from_catalog/service_info')
      require_relative('install_from_catalog/component_info')

      attr_reader :catalog, :module_ref, :directory_path, :version
      def initialize(catalog, module_ref, directory_path, version)
        @catalog        = catalog
        @module_ref     = module_ref
        @directory_path = directory_path
        @version        = version
      end
      private :initialize

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

        remote_module_info = rest_get "#{BaseRoute}/remote_module_info", query_string_hash

        @version ||= remote_module_info.required(:version)

        Operation::ClientModuleDir::GitRepo.create_empty_repo?(:repo_dir => target_repo_dir)

        if service_info = remote_module_info.data(:service_info)
          ServiceInfo.install_from_catalog(service_info['remote_repo_url'], target_repo_dir, self)
        end

        if component_info = remote_module_info.data(:component_info)
          ComponentInfo.install_from_catalog(component_info['remote_repo_url'], target_repo_dir, self)
        end

        {:target_repo_dir => target_repo_dir}
      end
      
      private

      def git_repo_remote_branch
        (@version && !@version.eql?('master')) ? "v#{@version}" : 'master'
      end

    end
  end
end


