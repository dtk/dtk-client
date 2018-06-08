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
      def initialize(catalog, module_ref, directory_path, version, base_dsl_file_obj, update_lock_file, force)
        @catalog           = catalog
        @module_ref        = module_ref
        @directory_path    = directory_path
        @target_repo_dir   = directory_path || base_dsl_file_obj.parent_dir
        @version           = version || module_ref.version || 'master'
        @base_dsl_file_obj = base_dsl_file_obj
        @update_lock_file  = update_lock_file
        @force             = force
        @module_ref.version ||= @version
      end
      private :initialize

      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          module_ref        = args.required(:module_ref)
          version           = args[:version]
          directory_path    = args[:directory_path]
          base_dsl_file_obj = args[:base_dsl_file_obj]
          update_lock_file  = args[:update_lock_file]
          force             = args[:force]
          new('dtkn', module_ref, directory_path, version, base_dsl_file_obj, update_lock_file, force).push_dtkn
        end
      end

      def push_dtkn
        # TODO: DTK-2765: not sure if we need module to exist on server to do push-dtkn
        unless module_version_exists?(@module_ref)
          raise Error::Usage, "Module #{@module_ref.print_form} does not exist on server"
        end

        if ref_version = @version || module_ref.version
          raise Error::Usage, "You are not allowed to push module version '#{ref_version}'!" unless ref_version.eql?('master')
        end

        @file_obj     = @base_dsl_file_obj.raise_error_if_no_content
        parsed_module = @file_obj.parse_content(:common_module_summary)

        module_info = {
          name:      module_ref.module_name,
          namespace: module_ref.namespace,
          version:   ref_version,
          repo_dir:  target_repo_dir
        }
        DtkNetworkClient::Push.run(module_info, parsed_module: parsed_module, update_lock_file: @update_lock_file, force: @force)

        nil
      end

    end
  end
end


