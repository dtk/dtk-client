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
        unless opts[:skip_prompt]
          module_ref_opts = { :namespace => module_ref.namespace }
          return unless Console.prompt_yes_no("Are you sure you want to delete module '#{DTK::Common::PrettyPrintForm.module_ref(module_ref.module_name, module_ref_opts)}' from repo manager?", :add_options => true)
        end

        module_info = {
          name:      module_ref.module_name,
          namespace: module_ref.namespace
        }
        DtkNetworkClient::Delete.run(module_info)

        nil
      end

    end
  end
end


