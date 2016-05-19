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

module DTK::DSL
  class DirectoryParser
    # For getting directory information when files in a vanilla file system
    class FileSystem < self
      # opts can have keys
      #  :current_dir if set means start from this dir; otherwise start from computed current dir
      def most_nested_matching_file_path?(path_info, opts = {})
        regexp       = path_info.regexp
        base_dir    = path_info.base_dir || OsUtil.home_dir
        current_dir = opts[:current_dir] || OsUtil.current_dir

        check_match_recurse_on_failure?(regexp, current_dir, base_dir)
      end
      # def matching_file_paths(path_info)
      # end
      
      private

      def check_match_recurse_on_failure?(regexp, current_dir, base_dir)
        match = matching_file_paths(current_dir, regexp)
        if match.empty?
          unless current_dir == base_dir
            if parent_path = OsUtil.parent_dir?(current_dir)
              check_match_recurse_on_failure?(regexp, parent_path, base_dir)
            end
          end
        elsif match.size == 1
          match.first
        else
          raise Error, "Unexpected that more than one match: #{match.join(', ')}"
        end
      end

      def matching_file_paths(dir_path, regexp)
        Dir.glob("#{dir_path}/*").select { |path| File.file?(path) and file_path_matches_regexp?(path, regexp) }
      end

      def file_path_matches_regexp?(file_path, regexp) 
        # extra check to see if regep is just for file part or has '/' seperators
        if '/' =~ regexp
          file_path.split(OsUtil.delim).last =~ Regexp.new("^#{regexp.source}$")
        else
          file_path =~ Regexp.new("#{regexp.source}$")
        end
      end
    end
  end
end

