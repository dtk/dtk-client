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

    def self.wait_animation(message, time_seconds)
      print message
      print " [     ]"
      STDOUT.flush
      time_seconds.downto(1) do
        1.upto(4) do |i|
          next_output = "\b\b\b\b\b\b\b"
          case
           when i % 4 == 0
            next_output  += "[ =   ]"
           when i % 3 == 0
             next_output += "[  =  ]"
           when i % 2 == 0
            next_output  += "[   = ]"
           else
            next_output  += "[  =  ]"
          end

          print next_output
          STDOUT.flush
          sleep(0.25)
        end
      end
      # remove loading animation
      print "\b\b\b\b\b\b\bRefreshing..."
      STDOUT.flush
      puts
    end

    private

    # Display confirmation prompt and repeat message until expected answer is given
    # options should be sent as array ['all', 'none']
    def self.confirmation_prompt_additional_options(message, options = [])
      raise DTK::Client::DtkValidationError, "Options should be sent as array: ['all', 'none']" unless options.is_a?(Array)

      # used to disable skip with ctrl+c
      trap("INT", "SIG_IGN")
      message += " (yes/no#{options.empty? ? '' : ('/' + options.join('/'))})"

      while line = Readline.readline("#{message}: ", true)
        if line.eql?("yes") || line.eql?("y")
          trap("INT",false)
          return true
        elsif line.eql?("no") || line.eql?("n")
          trap("INT",false)
          return false
        elsif options.include?(line)
          trap("INT",false)
          return line
        end
      end
    end

    def self.password_prompt(message, options = [])
      begin
        while line = (HighLine.ask("#{message}") { |q| q.echo = false})
          raise Interrupt if line.empty?
            return line
          end
        rescue Interrupt
          return nil
        ensure
          puts "\n" if line.nil?
        end
      end
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
