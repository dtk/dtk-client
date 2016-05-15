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
require 'highline/import'

module DTK::Client
  module Console
    # Display confirmation prompt and repeat message until expected answer is given
    #
    # opts can have keys
    #   :disable_ctrl_c - Boolean (default: true)
    #   :add_options - Boolean (default: false)
    def self.prompt_yes_no(message, opts = {})
      # used to disable skip with ctrl+c
      prompt_context(opts) do
        message += ' (yes|no)' if opts[:add_options]
        HighLine.agree(message)
      end
    end

    private

    # opts can have keys
    #   :disable_ctrl_c - Boolean (default: true)
    def self.prompt_context(opts = {}, &body)
      "#{opts[:disable_ctrl_c]}" == 'false' ? body.call : disable_ctrl_c(&body)
    end

    def self.disable_ctrl_c(&body)
      trap('INT', 'SIG_IGN')
      begin
        body.call
      ensure
        trap('INT', false)
      end
    end
  end
end