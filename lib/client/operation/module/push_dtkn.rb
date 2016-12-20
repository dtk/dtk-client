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
    class PushDtkn < self
      require_relative('push_dtkn/convert_source')

      attr_reader :version, :module_ref, :target_repo_dir, :base_dsl_file_obj
      def initialize(catalog, module_ref, directory_path, version, base_dsl_file_obj)
        @catalog           = catalog
        @module_ref        = module_ref
        @directory_path    = directory_path
        @target_repo_dir   = directory_path || OsUtil.current_dir
        @version           = version # if nil wil be dynamically updated
        @base_dsl_file_obj = base_dsl_file_obj
      end
      private :initialize

      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          module_ref        = args.required(:module_ref)
          version           = args[:version]
          directory_path    = args[:directory_path]
          base_dsl_file_obj = args[:base_dsl_file_obj]
          new('dtkn', module_ref, directory_path, version, base_dsl_file_obj).push_dtkn
        end
      end
      
      def push_dtkn
        # TODO: DTK-2765: not sure if we need module to exist on server to do push-dtkn
        unless module_version_exists?(@module_ref, :type => :common_module)
          raise Error::Usage, "Module #{@module_ref.print_form} does not exist on server"
        end

        if ref_version = @version || module_ref.version
          raise Error::Usage, "You are not allowed to push module version '#{ref_version}'!" unless ref_version.eql?('master')
        end

        error_msg = "To allow push-dtkn to go through, invoke 'dtk push' to push the changes to server before invoking push-dtkn again"
        DTK::Client::GitRepo.modified_with_diff?(@target_repo_dir, { :error_msg => error_msg })

        query_string_hash = QueryStringHash.new(
          :module_name => @module_ref.module_name,
          :namespace   => @module_ref.namespace,
          :rsa_pub_key => SSHUtil.rsa_pub_key_content,
          :version?    => @version
        )

        remote_module_info = rest_get "#{BaseRoute}/remote_module_info", query_string_hash

        @version ||= remote_module_info.required(:version)

        ConvertSource.transform_and_commit(remote_module_info, self)

        nil
      end

    end
  end
end


