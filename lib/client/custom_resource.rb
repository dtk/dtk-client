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
module DTK::Client
  class CustomResource
    require 'kubeclient'

    # require_relative('custom_resource/transform_to')
    require_relative('custom_resource/crd')
    require_relative('custom_resource/crd_instance')

    def initialize(transform_helper, info_type, parent)
      @info_processor   = transform_helper.info_processor(info_type)
      @info_type        = info_type
      @target_repo_dir  = parent[:target_repo_dir]
      @version          = parent[:version]
    end

    private :initialize

    def self.transform_and_apply(object_type, parent)
      target_repo_dir = parent[:target_repo_dir]
      fail "Unexpeceted that target directory does not exist" unless target_repo_dir

      parsed_common_module = parent[:base_dsl_file_obj].parse_content(:common_module)
      transform_helper = ServiceAndComponentInfo::TransformTo.new(target_repo_dir, parent[:module_ref], parent[:version], parsed_common_module)

      component_file_path__content_array =
        case object_type
        when :crd
          Crd.transform_info(transform_helper, object_type, parent)
        when :crd_instance
          CrdInstance.transform_info(transform_helper, object_type, parent)
        else
          fail "Unexpected custom resource type: #{object_type}!"
        end

      apply_to_kubernetes(component_file_path__content_array, object_type)
    end

    def self.transform_info(transform_helper, object_type, parent)
      new(transform_helper, object_type, parent).transform_info
    end

    def self.delete(resource_name)
      config = Kubeclient::Config.read("#{File.expand_path('~')}/.kube/config")
      context = config.context

      client = Kubeclient::Client.new(
        "#{context.api_endpoint}/apis/",
        "apiextensions.k8s.io/v1beta1",
        ssl_options: context.ssl_options,
        auth_options: context.auth_options
      )
      client.delete_custom_resource_definition(resource_name)
    end

      private

      attr_reader :info_processor, :target_repo_dir, :parent

      def self.apply_to_kubernetes(component_file_path__content_array, object_type)
        config = Kubeclient::Config.read("#{File.expand_path('~')}/.kube/config")
        context = config.context
        api_version = nil

        api_version =
          case object_type
          when :crd
            'apiextensions.k8s.io/v1beta1'
          when :crd_instance
            'dtk.io/v1alpha1'
          else
            fail "Unsupported object type: #{object_type}!"
          end

        client = Kubeclient::Client.new(
          "#{context.api_endpoint}/apis/",
          api_version,
          ssl_options: context.ssl_options,
          auth_options: context.auth_options
        )

        component_file_path__content_array.each do |name, content|
          crd = Kubeclient::Resource.new(content)
          client.create_componentdef(crd)

          # entity_type, resource_name, entity_config, klass
          # client.create_entity('Componentdef', 'namespaces/default/componentdef', crd)

          # existing_crd = nil
          # begin
          #   existing_crd = client.get_custom_resource_definition(crd.metadata.name)
          # rescue KubeException => e
          # end

          # if existing_crd# = client.get_custom_resource_definition(crd.metadata.name)
            # crd.metadata.resourceVersion = existing_crd.metadata.resourceVersion
            # client.update_custom_resource_definition(crd)
          # else
            # client.create_custom_resource_definition(crd)
          # end
        end
      end

  end
end
