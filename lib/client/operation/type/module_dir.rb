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
require 'fileutils'

module DTK::Client
  class Operation
    # Operations for managing module folders
    class ModuleDir < self
      require_relative('module_dir/git_repo')
      
      # opts can have keys:
      #  :backup_if_exist (optional) - Boolean
      def create_module_dir(type, module_ref, opts = {})
        path = module_dir_path(type, module_ref)
        if File.exists?(path)
          # if local copy of module exists then move that module to backups location
          if opts[:backup_if_exist]
            backup_dir = backup_dir(type, module_ref)
            FileUtils.mv(target_repo_dir, backup_dir)
            OsUtil.print_warning("Backup of existing module directory moved to '#{backup_dir}'")
          else
            raise Error::Usage, "Directory '#{path}' is not empty; it must be deleted or removed before retrying the command"
          end
        end
        FileUtils.mkdir_p(path)
        path
      end
    end
  end
end
=begin
      def self.module_dir_path(type, module_ref)
        target_repo_dir = module_dir_path(type, module_ref)
        
        
        full_name = module_namespace ? ModuleUtil.resolve_name(module_name, module_namespace) : module_name
        
        modules_dir = modules_dir(type,full_name,version,opts)
        FileUtils.mkdir_p(modules_dir) unless File.directory?(modules_dir)

        target_repo_dir = local_repo_dir(type,full_name,version,opts)

      end

      private

      def self.base_path(type)
        path =
          case type.to_sym
          when :service_module then Config[:service_location]
          when :component_module then Config[:module_location]
          when :service then Config[:instance_location]
          else raise Error, "Unexpected type (#{type}) when determining base path"
          end
        
        final_path = path && path.start_with?('/') ? path : "#{dtk_local_folder}#{path}"
        # remove last slash if set in configuration by mistake
        final_path.gsub(/\/$/,'')
      end
    end
  end
end
=end

