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
    class Describe < self
      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          service_instance  = args.required(:service_instance)
          path              = args[:path]
          show_steps        = args[:show_steps]
          query_string_hash = QueryStringHash.new

          raise Error, 'Option --show-steps can only be used with actions path' if show_steps && !actions_path_valid?(path)

          query_string_hash.merge!(path: path) if path
          query_string_hash.merge!(show_steps: show_steps) if show_steps
          response = rest_get "#{BaseRoute}/#{service_instance}/describe", query_string_hash

          response.set_render_as_table! if show_steps
          response
        end
      end

      def self.actions_path_valid?(path)
        prefix, suffix = (path||'').split('/')
        prefix.eql? 'actions'
      end

    end
  end
end
