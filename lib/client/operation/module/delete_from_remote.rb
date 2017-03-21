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
  class Operation::Module
    class DeleteFromRemote < self
      attr_reader :module_ref

      def initialize(catalog, module_ref)
        @catalog    = catalog
        @module_ref = module_ref
      end
      private :initialize

      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          module_ref  = args.required(:module_ref)
          new('dtkn', module_ref).delete_from_remote(:skip_prompt => args[:skip_prompt], :force => args[:force])
        end
      end
      
      def delete_from_remote(opts = {})
        query_string_hash = QueryStringHash.new(
          :module_name => module_ref.module_name,
          :namespace   => module_ref.namespace,
          :rsa_pub_key => SSHUtil.rsa_pub_key_content
          # :force?    => opts[:force]
        )

        unless version = module_ref.version
          remotes = Operation::Module.list_remotes({})

          selected_module = remotes.data.find{ |vr| vr['display_name'].eql?("#{module_ref.namespace}/#{module_ref.module_name}") }
          raise Error::Usage, "Module '#{module_ref.namespace}/#{module_ref.module_name}' does not exist on repo manager!" unless selected_module

          versions = selected_module['versions']
          versions.map! { |v| v == 'base' ? 'master' : v }

          if versions.size > 1
            ret_version = Console.version_prompt(versions, "Select which module version to delete: ", { :add_all => true })
            return unless ret_version
            version = ret_version
          else
            version = versions.first
          end
        end

        query_string_hash.merge!(:version => version)
        query_string_hash.merge!(:versions => versions) if version.eql?('all')

        unless opts[:skip_prompt]
          module_ref_opts = { :namespace => module_ref.namespace }
          module_ref_opts.merge!(:version => version) unless version.eql?('all')
          return unless Console.prompt_yes_no("Are you sure you want to delete module '#{DTK::Common::PrettyPrintForm.module_ref(module_ref.module_name, module_ref_opts)}' from repo manager?", :add_options => true)
        end

        rest_post "#{BaseRoute}/delete_from_remote", query_string_hash

        nil
      end

    end
  end
end


