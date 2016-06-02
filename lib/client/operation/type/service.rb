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
  class Operation
    class Service < self
      BaseRoute = 'services'

      def self.stage(args = Args.new)
        post_body = {
          :namespace => 'dtk-jira',
          :module_name => 'dtk2554',
          :assembly_name => 'foo'
        }
        rest_post("#{BaseRoute}/create", post_body)
      end
    end
  end
end


