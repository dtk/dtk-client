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
        file_type, file_path = matching_type_and_path?(Array(file_types), opts)
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
      #  :flag
      # returns nil or [file_type, path]
      def matching_type_and_path?(file_types, opts = {})
        matches = 
          if path = opts[:file_path]
            file_types.map { | file_type | file_type.matches?(path) && [file_type, path] }.compact
          else
            base_dir = OsUtil.home_dir
            current_dir = opts[:dir_path] || OsUtil.current_dir
            most_nested_matching_types_and_paths(file_types, current_dir, base_dir, flag: opts[:flag])
          end
        
        case matches.size
        when 0
          nil
        when 1
          matches.first
        else
          MultipleMatches.resolve(matches)
        end
      end

      # opts can have keys
      #   :flag
      def most_nested_matching_types_and_paths(file_types, current_dir, base_dir, opts = {})
        # matches will be an array of [file_type, path]
        matches = []
        file_types.each do |file_type| 
          matching_file_paths(current_dir, file_type).each { |path|  matches << [file_type, path] }
        end

        return matches unless matches.empty?

        next_level_matches = []
        unless current_dir == base_dir or opts[:flag]
          if parent_path = OsUtil.parent_dir?(current_dir)
            next_level_matches = most_nested_matching_types_and_paths(file_types, parent_path, base_dir, opts)
          end
        end
        next_level_matches
      end


      # returns an array of strings that are file paths; except bakup files (e.g. bak.dtk.service.yaml)
      def matching_file_paths(dir_path, path_info)
        Dir.glob("#{dir_path}/*").select { |file_path| File.file?(file_path) and !is_backup_file?(file_path) and path_info.matches?(file_path) }
      end

      def is_backup_file?(file_path)
        regex = Regexp.new("\.bak\.dtk\.(service|module)\.(yml|yaml)$")
        file_path =~ regex
      end

      module MultipleMatches
        def self.resolve(matches)
          augmented_matches = matches.map { |match| { match: match, ranking: type_ranking(match[0]) } }
          not_treated_types = augmented_matches.select { |aug_match| aug_match[:ranking].nil? }
          fail Error, "No ranking for types: #{not_treated_types.map { |aug_match| aug_match[:match][0] }.join(', ')}" unless not_treated_types.empty?

          ndx_matches = {}
          augmented_matches.each { |aug_match| (ndx_matches[aug_match[:ranking]] ||= []) << aug_match[:match] }
          top_matches = ndx_matches[ndx_matches.keys.sort.first]
          fail Error, "Cannot choice between types: #{top_matches.map{ |match| match[0] }.join(', ')}" if top_matches.size > 1
          top_matches.first
        end

        def self.type_ranking(type)
          ranking_for_types[type]
        end
        
        # lower is preferred
        def self.ranking_for_types
          @ranking_for_types ||= {
            DTK::DSL::FileType::CommonModule::DSLFile::Top => 2,
            DTK::DSL::FileType::ServiceInstance::DSLFile::Top => 1
          }
        end
      end

    end
  end
end; end


