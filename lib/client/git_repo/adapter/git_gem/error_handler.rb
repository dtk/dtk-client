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
  class GitRepo::Adapter::GitGem
    module ErrorHandler
      module Mixin
        private

        def handle_git_error(&block)
          ErrorHandler.handle_git_error(&block)
        end
      end        

      def self.handle_git_error(&block)
        begin
          yield
         rescue => e
          unless e.respond_to?(:message)
            raise e
          else
            raise Error::Usage, user_friendly_message(e.message)
          end
        end
      end

      private

      def self.user_friendly_message(message)
        user_friendly_message = 
          case message
          when /repository not found/i
            "Repository not found"
          when /repository (.*) not found/i
            "Repository #{$1.strip()} not found"
          when /destination path (.*) already exists/i
            "Destination folder #{$1.strip()} already exists"
          when /Authentication failed for (.*)$/i
            "Authentication failed for given repository #{$1.strip()}"
          when /timed out/
            "Timeout - not able to contact remote"
          else
            lines = message.split("\n")
            if lines.last =~ GitErrorPattern
              last_line = message.last.gsub(GitErrorPattern,'').strip
              if last_line =~ /adding files failed/ and lines.first =~ /\.git/
                "Cannot add files that are in a .git directory; remove any nested .git directory'"
              end
            end
          end
        user_friendly_message || message
      end
      GitErrorPattern = /^fatal:/
    end
  end
end
