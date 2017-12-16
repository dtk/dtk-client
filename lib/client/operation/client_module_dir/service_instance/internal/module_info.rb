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
  class Operation::ClientModuleDir
    class ServiceInstance::Internal
      class ModuleInfo
        def initialize(module_info_hash)
          @module_info_hash = module_info_hash
        end
        
        def repo_url
          index(:repo, :url)
        end
        
        def branch
          index(:branch, :name)
        end
        
        def module_name
          index(:module, :name)
        end
        
        protected
        
        attr_reader :module_info_hash
        
        private
        
        def index(index1, index2)
          index?(index1, index2) || raise_error_missing_key(index1, index2)
        end     
        
        def index?(index1, index2)
          (self.module_info_hash[index1.to_s] || {})[index2.to_s]
        end
        
        def raise_error_missing_key(index1, index2)
          if module_name = index?(:module, :name) 
            if module_namespace = index?(:module, :namespace)
              module_name = "#{module_name}:#{module_namespace}"
            end
          end
          module_name ||= 'module'
          raise Error, "Unexpected that #{module_name}[#{index1}][#{index2}] is nil"
        end 

      end
    end
  end
end


