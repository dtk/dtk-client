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

# TODO: move functions taht parse to ::DTK::DSL::ServiceAndComponentInfo::TransformFrom

module DTK::Client
  module ServiceAndComponentInfo
    class TransformFrom
      def initialize(content_dir, module_ref, version)
        @content_dir = content_dir
        @module_ref  = module_ref
        @version     = version
        @indexed_input_files = service_info_parse_helper.indexed_input_files

        # dynamically set
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

      def service_info_parse_helper
        @service_info_parse_helper ||= ::DTK::DSL::ServiceAndComponentInfo::TransformFrom::ServiceInfo.new
      end

      def assembly_input_files 
        @assembly_input_files ||= @indexed_input_files[:assemblies] || raise(Error, "Unexpected that @indexed_input_files[:assemblies] is nil")
      end

      def module_ref_input_files
        @module_ref_input_files ||= @indexed_input_files[:module_refs] || raise(Error, "Unexpected that @indexed_input_files[:module_refs] is nil")
      end

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
        get_directory_content.select { |path| assembly_input_files.match?(path) }
      end
      
      def get_module_refs_file
        matches = get_directory_content.select { |path| module_ref_input_files.match?(path) }
        raise Error, "Unexpected that multiple module ref files" if matches.size > 1
        matches.first
      end
      
      def ret_assemblies_hash
        assemblies = {}
        
        get_assembly_files.each do |assembly|
          # TODO: replace below with loop that does add_content! and then processes in dtk dsl
          # assembly_input_files.add_content!(assembly, get_raw_content?(assembly))

          content_hash     = convert_file_content_to_hash(assembly)
          name             = content_hash['name']
          assembly_content = content_hash['assembly']
          
          workflows = ret_workflows_hash(content_hash)
          assembly_content.merge!('workflows' => workflows) if workflows
          
          # convert node_bindings to node attributes
          node_bindings = content_hash['node_bindings']
          create_node_properties_from_node_bindings?(node_bindings, assembly_content)
          
          assemblies.merge!(name => assembly_content)
        end
        
        assemblies.empty? ? nil : assemblies
      end
      
      def ret_workflows_hash(content_hash)
        if workflows = content_hash['workflow'] || content_hash['workflows']
          # this is legacy workflow
          if workflow_name = workflows.delete('assembly_action')
            { workflow_name => workflows }
          else
            workflows
          end
        end
      end
      
      def ret_dependencies_hash
        if file_path = get_module_refs_file
          module_refs_content = convert_file_content_to_hash(file_path)
          dependencies = {}
          
          if cmp_dependencies = module_refs_content['component_modules']
            cmp_dependencies.each_pair do |name, namespace_h|
              dependencies.merge!({ "#{namespace_h['namespace']}/#{name}" => namespace_h['version']||'master' })
            end
          end
          
          dependencies
        end
      end
      
      def create_node_properties_from_node_bindings?(node_bindings, assembly_content = {})
        return unless node_bindings

        nodes = assembly_content['nodes']
        return if nodes.empty?
        
        node_bindings.each do |node, node_binding|
          image, size = get_ec2_properties_from_node_binding(node_binding)
          new_attrs = { 'image' => image, 'size' => size }
          
          if node_content = nodes[node]
            components = node_content['components']
            components = components.is_a?(Array) ? components : [components]
            
            if index = include_node_property_component?(components)
              ec2_properties = components[index]
              if ec2_properties.is_a?(Hash)
                if attributes = ec2_properties.values.first['attributes']
                  attributes['image'] = image unless attributes['image']
                  attributes['size'] = size unless attributes['size']
                else
                  ec2_properties.merge!('attributes' => new_attrs)
                end
              else
                components[index] = { ec2_properties => { 'attributes' => new_attrs } }
              end
            elsif node_attributes = node_content['attributes']
              node_attributes['image'] = image unless node_attributes['image']
              node_attributes['size'] = size unless node_attributes['size']
            else
              node_content['attributes'] = new_attrs
            end
          end
        end
      end

      def get_ec2_properties_from_node_binding(node_binding)
        image, size = node_binding.split('-')
        [image, size]
      end

      def include_node_property_component?(components)
        property_component = 'ec2::properties'
        components.each do |component|
          if component.is_a?(Hash)
            return components.index(component) if component.keys.first.eql?(property_component)
          else
            return components.index(component) if component.eql?(property_component)
          end
        end

        false
      end

    end
  end
end
