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

module DTK::Client; module CLI
  class DirectoryParser
    # For Finding relevant content when files in a vanilla file system
    class FileSystem < self 
      # file_types - a single or array of FileObj objects
      # opts can have keys
      #   :file_path - string
      #   :dir_path - string
      # Returns FileObj object or nil that match a file_type
      def matching_file_obj?(file_types, opts = {})
        ret = nil
        file_types = [file_types] unless file_types.kind_of?(Array)

        file_type, file_path = matching_type_and_path?(file_types, opts)
        file_obj_opts = {
          dir_path: opts[:dir_path],
          current_dir: OsUtil.current_dir,
          content: get_content?(file_path)
        }
        FileObj.new(file_type, file_path, file_obj_opts)
      end
      
      private

      def get_content?(file_path)
        File.open(file_path).read if file_path and File.exists?(file_path)
      end

      # This method finds the base dsl file if it exists and returns its path
      # opts can have keys:
      #  :dir_path
      #  :file_path
      # returns nil or [file_type, path]
      def matching_type_and_path?(file_types, opts = {})
        ret = nil
        flag = opts[:flag]
        if path = opts[:file_path]
          file_types.each do | file_type |
            if file_type.matches?(path)
              return [file_type, path]
            end
          end
        else
          file_types.each do | file_type |
            path_info = file_type.create_path_info
            if path = most_nested_matching_file_path?(path_info, flag, :current_dir => opts[:dir_path])
              return [file_type, path]
            end
          end
        end
        ret
      end

      # return either a string file path or of match to path_info working from current directory and 'otwards'
      # until base_path in path_info (if it exists)
      # opts can have keys
      #  :current_dir if set means start from this dir; otherwise start from computed current dir
      def most_nested_matching_file_path?(path_info, flag, opts = {})
        base_dir = path_info.base_dir || OsUtil.home_dir
        current_dir = opts[:current_dir] || OsUtil.current_dir
        check_match_recurse_on_failure?(path_info, current_dir, base_dir, flag)
      end

      def check_match_recurse_on_failure?(path_info, current_dir, base_dir, flag)
        match = matching_file_paths(current_dir, path_info)
        if match.empty?
          unless current_dir == base_dir
            if parent_path = OsUtil.parent_dir?(current_dir)
              check_match_recurse_on_failure?(path_info, parent_path, base_dir, flag) unless flag
            end
          end
        elsif match.size == 1
          match.first
        else
          raise Error, "Unexpected that more than one match: #{match.join(', ')}"
        end
      end

      # returns an array of strings that are file paths; except bakup files (e.g. bak.dtk.service.yaml)
      def matching_file_paths(dir_path, path_info)
        Dir.glob("#{dir_path}/*").select { |file_path| File.file?(file_path) and !is_backup_file?(file_path) and path_info.matches?(file_path) }
      end

      def is_backup_file?(file_path)
        regex = Regexp.new("\.bak\.dtk\.(service|module)\.(yml|yaml)$")
        file_path =~ regex
      end
    end
  end
end; end


