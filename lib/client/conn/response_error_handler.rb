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
  class Conn
    class ResponseErrorHandler
      def self.check_for_session_expiried(response)
        error_code = nil
        if response && response['errors']
          response['errors'].each do |err|
            error_code      = err['code']||(err['errors'] && err['errors'].first['code'])
          end
        end
        (error_code == 'forbidden')
      end
      
      def self.check(response)
        Error.raise_if_error?(response)
      end
    end
  end
end
