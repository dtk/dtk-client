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
    class Push < self
      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          # TODO: see if want to push in service instance path as well or make an object that has service instance name and path
          service_instance = args.required(:service_instance)
          commit_sha =  head_commit_sha(service_instance)
          rest_post("#{BaseRoute}/#{service_instance}/update_from_repo", :commit_sha => head_commit_sha)
        end
      end

      private
      def head_commit_sha(service_instance)
        raise Error, "Need to write"
      end
    end
  end
end


