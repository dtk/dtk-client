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
      
      def self.create_service_dir(service_name)
        # since option, backup_if_exist is not set on create_service_dir, this will fail on
        create_service_dir?(service_name)
      end

      # opts can have keys
      #  backup_if_exist (optional) - Boolean
      def self.create_service_dir?(service_name, opts = {})
        path = "#{base_path(:service)}/#{service_name}"
        if File.exists?(path)
          # TODO: put back in after refernced methods are ported over
          # if local copy of module exists then move that module to backups location
          # if opts[:backup_if_exist]
          #  backup_dir = backup_dir(type, module_ref)
          #  FileUtils.mv(target_repo_dir, backup_dir)
          #  OsUtil.print_warning("Backup of existing module directory moved to '#{backup_dir}'")
          # else
          # raise Error::Usage, "Directory '#{path}' is not empty; it must be deleted or removed before retrying the command"
          #end
          raise Error::Usage, "Directory '#{path}' is not empty; it must be deleted or removed before retrying the command"
        end
        FileUtils.mkdir_p(path)
        path
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
        
        # see if path is relative or not
        final_path = path && path.start_with?('/') ? path : "#{OsUtil.dtk_local_folder}/#{path}"
        # remove last slash if set in configuration by mistake
        final_path.gsub(/\/$/,'')
      end
    end
  end
end

