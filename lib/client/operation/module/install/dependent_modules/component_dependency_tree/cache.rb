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
  class Operation::Module::Install::DependentModules::ComponentDependencyTree
    class Cache < ::Hash
      # hash where key unqiuely determines module_refs and value is to hash with keys :module_ref and :dependencies 
      def initialize
        super()
      end

      def add!(module_ref, dependencies)
        self[index(module_ref)] ||= {:module_ref => module_ref, :dependencies => dependencies }
      end

      def lookup_dependencies?(module_ref)
        (self[index(module_ref)] || {})[:dependencies]
      end

      def all_modules_refs
        values.map { |hash| hash[:module_ref] }
      end

      private

      def index(module_ref)
        "#{module_ref.module_name}--#{module_ref.namespace}--#{module_ref.version}"
      end

    end
  end
end

