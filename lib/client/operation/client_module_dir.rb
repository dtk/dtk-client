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
    class ClientModuleDir < self
      require_relative('client_module_dir/git_repo')
      require_relative('client_module_dir/service_instance')
      
      NAMESPACE_SEPERATOR = ':'
      # opts can have keys
      #   :backup_if_exist - Boolean (default: false)
      #   :remove_existing - Boolean (default: false)
      def self.create_service_dir(service_instance, opts = {})
        path = opts[:path]
        path = "#{base_path(:service)}/#{service_instance}" if path.nil?
        if File.exists?(path)
          if opts[:remove_existing]
            FileUtils.rm_rf(path)
          else
            # TODO: put back in after referenced methods are ported over
            # if local copy of module exists then move that module to backups location
            # if opts[:backup_if_exist]
            #  backup_dir = backup_dir(type, module_ref)
            #  FileUtils.mv(target_repo_dir, backup_dir)
            #  OsUtil.print_warning("Backup of existing module directory moved to '#{backup_dir}'")
            # else
            # raise Error::Usage, "Directory '#{path}' is not empty; it must be deleted or moved before retrying the command"
            #end
            raise Error::Usage, "Directory '#{path}' is not empty; it must be deleted or moved before retrying the command" unless (Dir.entries(path) - %w{ . .. }).empty?
            return path
          end
        end
        FileUtils.mkdir_p(path)
        path
      end

      def self.create_module_dir(module_type, module_name, opts = {})
        path = opts[:path]

        unless path
          base_module_path = base_path(module_type)

          path_parts =
            if (module_name.match(/(.*)#{NAMESPACE_SEPERATOR}(.*)/))
              [base_module_path, "#{$1}", "#{$2}"]
            else
              [base_module_path, "#{module_name}"]
            end

          path = path_parts.compact.join('/')
        end

        if File.exists?(path)
          if opts[:remove_existing]
            FileUtils.rm_rf(path)
          else
            raise Error::Usage, "Directory '#{path}' is not empty; it must be deleted or moved before retrying the command" unless (Dir.entries(path) - %w{ . .. }).empty?
            return path
          end
        end

        FileUtils.mkdir_p(path)
        path
      end

      def self.create_module_dir_from_path(path, opts = {})
        if File.exists?(path)
          if opts[:remove_existing]
            FileUtils.rm_rf(path)
          else
            raise Error::Usage, "Directory '#{path}' is not empty; it must be deleted or moved before retrying the command" unless (Dir.entries(path) - %w{ . .. }).empty?
            return path
          end
        end

        FileUtils.mkdir_p(path)
        path
      end

      def self.local_dir_exists?(type, name, opts = {})
        File.exists?("#{base_path(type)}/#{name}")
      end

      def self.ret_base_path(type, name)
        "#{base_path(type)}/#{name}"
      end

      def self.ret_path_with_current_dir(name)
        "#{OsUtil.current_dir}/#{name.gsub(':','/')}"
      end

      def self.rm_f(path)
        FileUtils.rm_rf(path)
      end

      def self.delete_directory_content(path)
        FileUtils.rm_rf(Dir.glob("#{path}/*"))
      end

      def self.create_file_with_content(file_path, content)
        FileUtils.mkdir_p(File.dirname(file_path))
        File.open(file_path, 'w') { |f| f << content }
      end
    
      private

      def self.response_data_hash(hash = {})
        hash.inject({}) { |h, (k, v)| h.merge(k.to_s => v) }
      end

      def self.base_path(type)
        path =
          case type.to_sym
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

