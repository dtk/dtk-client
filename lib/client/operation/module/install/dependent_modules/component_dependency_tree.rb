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
module DTK::Client; class Operation::Module
  class Install::DependentModules
    class ComponentDependencyTree <  Operation::Module
      require_relative('component_dependency_tree/cache')
      include Install::Mixin

      BaseRoute  = "modules"

      # opts can have keys:
      #   :children_module_refs
      #   :cached
      def initialize(module_ref, opts = {})
        @module_ref         = module_ref
        @cache              = opts[:cache] || Cache.new
        @children           = children_from_module_refs(opts[:children_module_refs] || [], @cache)
        @first_level_added  = !opts[:children_module_refs].nil?
      end
      private :initialize

      def self.create(module_ref, children_module_refs)
        new(module_ref, :children_module_refs => children_module_refs).recursively_add_children!
      end

      def recursively_add_children!
        unless @first_level_added
          raise Error, "Unexpected that @children is not empty" unless @children.empty?
          @children = children_from_module_refs(get_children_module_refs, @cache)
          @first_level_added = true
        end

        @children.each { |child| child.recursively_add_children! }
        self
      end

      def resolve_versions_and_return_all_module_refs
        # TODO: change this simplistic method which does not take into accunt the nested structure.
        resolve_conflicts(@cache.all_modules_refs)
      end

      private

      def children_from_module_refs(module_refs, cache)
        module_refs.map { |module_ref| self.class.new(module_ref, cache: cache) }
      end

      # returns module refs array or raises error
      def get_children_module_refs
        @cache.lookup_dependencies?(@module_ref) || get_children_module_refs_aux
      end

      def get_children_module_refs_aux
        response = nil
        begin
          hash = {
            :module_name => module_name,
            :namespace   => namespace,
            :rsa_pub_key => SSHUtil.rsa_pub_key_content,
            :version?    => version
          }
          response = rest_get "#{BaseRoute}/module_dependencies", QueryStringHash.new(hash)
        rescue Error::ServerNotOkResponse => e
          # temp fix for issue when dependent module is imported from puppet forge
          if errors = e.response && e.response['errors']
            response = nil if errors.first.include?('not found')
          else
            raise e
          end
        end

        dependencies = convert_to_module_refs_array(response)
        @cache.add!(@module_ref, dependencies)
        dependencies
      end

      def convert_to_module_refs_array(module_dependencies_response)
        response = module_dependencies_response #alias
        ret = []
        return ret unless response

        # processing warning messages, :missing_module_components and :required_modules
        process_if_warnings(response)

        if missing_modules = response.data(:missing_module_components)
          ret += missing_modules.map { |ref_hash| create_module_ref(ref_hash, :module_installed => false) }
        end

        if required_modules = response.data(:required_modules)
          ret += required_modules.map { |ref_hash| create_module_ref(ref_hash, :module_installed => true) }
        end

        ret
      end

      def process_if_warnings(module_dependencies_response)
        are_there_warnings = RemoteDependency.check_permission_warnings(module_dependencies_response)
        are_there_warnings ||= RemoteDependency.print_dependency_warnings(module_dependencies_response, nil, :ignore_permission_warnings => true)
        if are_there_warnings
          raise TerminateInstall unless Console.prompt_yes_no("Do you still want to proceed with install?", :add_options => true)
        end
      end

      # opts can have keys:
      #   :module_installed
      def create_module_ref(ref_hash, opts = {})
        module_ref_hash = {
          :namespace => ref_hash['namespace'], 
          :module_name => ref_hash['name'], 
          :version => ref_hash['version']
        }
        module_ref_hash.merge!(:module_installed => opts[:module_installed]) if opts.has_key?(:module_installed)
        Install::ModuleRef.new(module_ref_hash)
      end

      # TODO: DTK-2766: refine this very simple version of resolve_conflicts taking as input the nested structure, rather than flat list
      def resolve_conflicts(module_refs)
        ret = []
        module_refs.each do |module_ref|
          # TODO: DTK-2766: handle version conflicts, initially by ignoring, but printing message about conflct and what is chosen
          #       more advanced could replace what is in ret and choose modules_ref over it
          ret << module_ref unless is_conflict?(module_ref, ret)
        end
        ret
      end

      def is_conflict?(module_ref, existing_module_refs)
        is_conflict = false
        module_name = module_ref.module_name
        if match = existing_module_refs.find { |existing_module_ref| existing_module_ref.module_name == module_name }
          # see if the match is same version and namespace
          unless existing_module_ref.namespace == module_ref.namespace and existing_module_ref.version == module_ref.version
            is_conflict = true
          end
        end
        is_conflict
      end

    end
  end
end; end
