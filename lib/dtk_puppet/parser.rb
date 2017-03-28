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
module DTK
  module Puppet
    class Parser
      def self.parse(argv)
        Client::Error.top_level_trap_error do
          parse_puppet_module_directory
        end
      end

      def self.parse_puppet_module_directory
        begin
          require 'puppet'
        rescue LoadError => e
          fail DTK::Client::Error::Usage.new("Puppet gem is not installed on your system. Please install it and try again.")
        end

        current_dir = Client::OsUtil.current_dir
        dir_content = Dir.glob("#{current_dir}/**/*")

        if module_yaml_file = dir_content.find { |path| path =~ /dtk.module.yaml$/ }
          fail DTK::Client::Error::Usage.new("Dtk module file 'dtk.module.yaml' exists already. Please delete it first and execute puppet scaffolding again.")
        end

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

        component_defs = process_manifest_files(all_files, module_name)
        module_hash['component_defs'] = component_defs

        File.open("#{current_dir}/dtk.module.yaml", 'wb') { |file| file.write(module_hash.to_yaml) }
        DTK::Client::OsUtil.print_info("'dtk.module.yaml' file has been created successfully.")
      end

      def self.process_manifest_files(files, module_name)
        ret    = ParseStructure::TopPS.new()
        parser = ::Puppet::Parser::ParserFactory.parser

        files.each do |file|
          parser.file    = file
          initial_import = parser.parse

          known_resource_types = ::Puppet::Resource::TypeCollection.new('production')
          known_resource_types.import_ast(initial_import, '')
          krt_code = known_resource_types.hostclass('').code

          ret.add_children(krt_code)
        end

        ret.render_hash_form(module_name)
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
