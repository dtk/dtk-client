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
require 'puppet'

module DTK
  module Puppet
    class Parser
      def self.parse(argv)
        Client::Error.top_level_trap_error do
          parse_puppet_module_directory
        end
      end

      def self.parse_puppet_module_directory
        current_dir = Client::OsUtil.current_dir
        dir_content = Dir.glob("#{current_dir}/**/*")

        metadata_file = dir_content.find { |path| path =~ /metadata.json$/ }
        file_content  = File.read(metadata_file)
        metadata_hash = JSON.parse(file_content)

        full_module_name = metadata_hash['name'].gsub('-', '/')
        module_version   = metadata_hash['version']
        dependencies     = process_metadata_dependencies(metadata_hash['dependencies'])

        module_hash = {
          'module' => full_module_name,
          'version' => module_version
        }
        module_hash.merge!('dependencies' => dependencies) unless dependencies.empty?

        all_files = dir_content.select { |path| path =~ /manifests.+\.pp$/ }
        if all_files.empty?
          all_files = dir_content.select { |path| path =~ /puppet\/manifests.+\.pp$/ }
        end

        namespace, module_name = full_module_name.split('/')
        content = PuppetStructure.new(all_files, module_name).parse_pp_files
        module_hash.merge!(content)

        File.open("#{current_dir}/dtk.module.yaml", 'wb') { |file| file.write(module_hash.to_yaml) }
      end

      def self.process_metadata_dependencies(dependencies)
        dependency_hash = {}

        if dependencies
          dependencies.each do |dependency|
            dependency_hash.merge!(dependency['name'] => 'master')
          end
        end

        dependency_hash
      end
    end
  end
end
