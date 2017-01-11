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
    class PullDtkn < self
      attr_reader :version, :module_ref, :target_repo_dir, :base_dsl_file_obj
      def initialize(catalog, module_ref, directory_path, version, base_dsl_file_obj)
        @catalog           = catalog
        @module_ref        = module_ref
        @directory_path    = directory_path
        @target_repo_dir   = directory_path || base_dsl_file_obj.parent_dir
        @version           = version # if nil wil be dynamically updated
        @base_dsl_file_obj = base_dsl_file_obj
      end
      private :initialize

      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          module_ref        = args.required(:module_ref)
          version           = args[:version] || module_ref.version
          base_dsl_file_obj = args[:base_dsl_file_obj]
          directory_path    = args[:directory_path]
          new('dtkn', module_ref, directory_path, version, base_dsl_file_obj).pull_dtkn
        end
      end
      
      def pull_dtkn
        # TODO: DTK-2765: not sure if we need module to exist on server to do push-dtkn
        unless module_version_exists?(@module_ref, :type => :common_module)
          raise Error::Usage, "Module #{@module_ref.print_form} does not exist on server"
        end

        if ref_version = @version || module_ref.version
          raise Error::Usage, "You are not allowed to pull module version '#{ref_version}'!" unless ref_version.eql?('master')
        end

        error_msg = "To allow pull-dtkn to go through, invoke 'dtk push' to push the changes to server before invoking pull-dtkn again"
        GitRepo.modified_with_diff?(@target_repo_dir, { :error_msg => error_msg })

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

        LoadSource.fetch_transform_and_merge(remote_module_info, self, :stage_and_commit_steps => true)
        nil
      end

    end
  end
end


