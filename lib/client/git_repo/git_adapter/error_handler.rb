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
  class GitRepo::GitAdapter
    module ErrorHandler
      module Mixin
        private

        def handle_git_error(&block)
          ErrorHandler.handle_git_error(&block)
        end
      end        

      def self.handle_git_error(&block)
        ret = nil
        begin
          ret = yield
        rescue => e
          unless e.respond_to?(:message)
            raise e
          else
            err_msg = e.message
            lines = err_msg.split("\n")
            if lines.last =~ GitErrorPattern
              err_msg = error_msg_when_git_error(lines)
            end
            raise Error::Usage, err_msg
          end
        end
        ret
      end

      GitErrorPattern = /^fatal:/
      def self.error_msg_when_git_error(lines)
        ret = lines.last.gsub(GitErrorPattern,'').strip
        # TODO start putting in special cases here
        if ret =~ /adding files failed/
          if lines.first =~ /\.git/
            ret = 'Cannot add files that are in a .git directory; remove any nested .git directory'
          end
        end
        ret
      end
    end
  end
end
