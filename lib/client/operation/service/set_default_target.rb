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
  class Operation::Service
    class SetDefaultTarget < self
      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          post_body = PostBody.new(
            :service_instance => args.required(:service_instance)
          )
          rest_post("#{BaseRoute}/set_default_target", post_body)
        end
      end
    end
  end
end
