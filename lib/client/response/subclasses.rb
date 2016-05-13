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
# This is wrapper for holding rest response information as well as
# passing selection of ViewProcessor from Thor selection to render view
# selection
module DTK::Client
  class Response
    class Ok < self
      def initialize(data = {})
        super('data'=> data, 'status' => 'ok')
      end
    end
    
    class NotOk < self
      def initialize(data = {})
        super('data'=> data, 'status' => 'notok')
      end
    end
    
    class NoOp < self
      def render_data
      end
    end
    
    class ErrorResponse < self
      include ::DTK::Common::Response::ErrorMixin
      def initialize(hash = {})
        super('errors' => [hash])
      end
      private :initialize
      
      class Usage < self
        def initialize(hash_or_string = {})
          hash = (hash_or_string.kind_of?(String) ? {'message' => hash_or_string} : hash_or_string)
          super({'code' => 'error'}.merge(hash))
        end
      end
      
      class Internal < self
        def initialize(hash = {})
          super({'code' => 'error'}.merge(hash).merge('internal' => true))
        end
      end
    end
  end
end

