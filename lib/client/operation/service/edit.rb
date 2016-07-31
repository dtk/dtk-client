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
    class Edit < self
      def self.execute(args = Args.new)
        ret = nil
        wrap_operation(args) do |args|
          service_instance   = args.required(:service_instance)
          absolute_file_path = args.required(:absolute_file_path)
          push_after_edit    = args[:push_after_edit]
          commit_message     = args[:commit_message]

          response = Pull.execute(:service_instance => service_instance)
          repo = response.required(:repo)

          OsUtil.edit(absolute_file_path)
          return ret unless push_after_edit and repo.changed?

          commit_message ||= Internal.prompt_for_commit_message

          push_args = {
            # TODO: put in needed args
            :commit_message => commit_message
          }
          Push.execute(args)
          ret
        end
      end

      module Internal
        def self.prompt_for_commit_message
          commit_msg = OsUtil.user_input("Commit message")
          commit_msg.gsub!(/\"/,'') unless commit_msg.count('"') % 2 ==0
          commit_msg
        end
      end

    end
  end
end
