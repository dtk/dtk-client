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
require 'yaml'

module DTK::Client
  # Abstract class that holds classes and methods for xecuting commands by
  # make calls to server and performing client side operations
  class ContentGenerator
    def initialize(content_dir, module_ref, version)
      @content_dir       = content_dir
      @module_ref        = module_ref
      @version           = version
      @directory_content = nil
    end

    def generate_module_content
      module_hash = {
        'dsl_version' => '1.0.0',
        'module'  => "#{@module_ref.namespace}/#{@module_ref.module_name}",
        'version' => @version || 'master'
      }

      if dependencies = ret_dependencies_hash
        module_hash.merge!('dependencies' => dependencies)
      end

      if assemblies = ret_assemblies_hash
        module_hash.merge!('assemblies' => assemblies)
      end

      module_hash
    end

    private

    def get_raw_content?(file_path)
      File.open(file_path).read if file_path and File.exists?(file_path)
    end

    def convert_file_content_to_hash(file_path)
      begin
        YAML.load(get_raw_content?(file_path))
      rescue Exception => e
        yaml_err_msg = e.message.gsub(/\(<unknown>\): /,'').capitalize 
        raise Error::Usage, "YAML parsing error in '#{file_path}':\n#{yaml_err_msg}"
      end
    end

    def get_directory_content
      @directory_content ||= Dir.glob("#{@content_dir}/**/*")
    end

    def invalidate_directory_content
      @directory_content = Dir.glob("#{@content_dir}/**/*")
    end

    def get_assembly_files
      get_directory_content.select { |f| f =~ AssemblyRegexp[:regexp] || f =~ AssemblyRegexp[:legacy_regexp] }
    end
    AssemblyRegexp = {
      :regexp        => Regexp.new("assemblies/(.*)\.dtk\.assembly\.(yml|yaml)$"),
      :legacy_regexp => Regexp.new("assemblies/([^/]+)/assembly\.(yml|yaml)$")
    }

    def get_module_refs_file
      get_directory_content.find { |f| f =~ ModuleRefsRegexp[:regexp] }
    end
    ModuleRefsRegexp = { 
      :regexp => Regexp.new("module_refs\.(yml|yaml)$")
    }

    def ret_assemblies_hash
      assemblies = {}

      get_assembly_files.each do |assembly|
        content_hash     = convert_file_content_to_hash(assembly)
        name             = content_hash['name']
        assembly_content = content_hash['assembly']
        workflows        = ret_workflows_hash(content_hash['workflow'])
        
        assembly_content.merge!('workflows' => workflows) if workflows
        assemblies.merge!(name => assembly_content)
      end

      assemblies.empty? ? nil : assemblies
    end

    def ret_workflows_hash(workflow)
      return if workflow.nil? || workflow.empty?
      workflow_name = workflow.delete('assembly_action')
      {
        workflow_name => workflow
      }
    end

    def ret_dependencies_hash
      if file_path = get_module_refs_file
        module_refs_content = convert_file_content_to_hash(file_path)
        dependencies = []

        if cmp_dependencies = module_refs_content['component_modules']
          cmp_dependencies.each_pair do |name, namespace_h|
            dependencies << "#{namespace_h['namespace']}/#{name}"
          end
        end

        dependencies
      end
    end
  end
end

