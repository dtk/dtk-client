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
require 'highline'
require 'colorize'

module DTK::Client
  class OsUtil
    module PrintMixin
      # Method will print to STDOUT with given color
      #
      # message - String to be colorize and printed
      # color   - Symbol describing the color to be used on STDOUT
      #
      def print(message, color = :white)
        puts colorize(message, color)
      end

      def print_info(message)
        print_with_prefix(:info, message, :yellow)
      end

      def print_warning(message)
        print_with_prefix(:warning, message, :yellow)
      end

      def print_error(message)
        print_with_prefix(:error, message, :red)
      end
      
      def put_warning(prefix, text, color)
        width = HighLine::SystemExtensions.terminal_size[0] - (prefix.length + 1)
        text_split = wrap(text, width)
        Kernel.print colorize(prefix, color), " "
        text_split.lines.each_with_index do |line, index|
          line = " "*(prefix.length + 1) + line unless index == 0
          puts line
        end
      end
    
      # Method will convert given string, to string with colorize output
      #
      # message - String to be colorized
      # color   - Symbol describing color to be used
      #
      # Returns String with colorize output
      def colorize(message, color)
        # at the moment we do not support colors in windows
        ((is_windows? || message.nil?) ? message : message.colorize(color))
      end
    
      private

      def wrap(text, wrap_at)
        wrapped = [ ]
        text.each_line do |line|
          # take into account color escape sequences when wrapping
          wrap_at = wrap_at + (line.length - actual_length(line))
          while line =~ /([^\n]{#{wrap_at + 1},})/
            search  = $1.dup
            replace = $1.dup
            if index = replace.rindex(" ", wrap_at)
              replace[index, 1] = "\n"
              replace.sub!(/\n[ \t]+/, "\n")
              line.sub!(search, replace)
            else
              line[$~.begin(1) + wrap_at, 0] = "\n"
            end
          end
          wrapped << line
        end
        wrapped.join
      end
      
      def actual_length(string_with_escapes)
        string_with_escapes.to_s.gsub(/\e\[\d{1,2}m/, "").length
      end

      def print_with_prefix(prefix, message, color)
        PrintWithPrefix.print(prefix, message, color)
      end
    end

    module PrintWithPrefix
      LEFT_DELIM = '['
      RIGHT_DELIM = ']'
      def self.print(prefix, message, color)
        prefix = prefix.to_s
        # only add prefix if does not have it already
        if already_has_prefix?(prefix, message)
          OsUtil.print(message, color)
        else
          OsUtil.print(add_prefix(prefix, message), color)
        end
      end
      
      def self.already_has_prefix?(prefix, message)
        prefix_regexps = [prefix, prefix.upcase].map { |p| [p, with_left_prefix(p)] }.flatten.map { |p| Regexp.new("^#{p}") }
        !!prefix_regexps.find {|regexp| message =~ regexp}      
      end

      def self.with_left_prefix(prefix)
        '\\' + LEFT_DELIM + prefix
      end

      def self.add_prefix(prefix, message)
        "#{LEFT_DELIM}#{prefix.upcase}#{RIGHT_DELIM} #{message}"
      end
    end
  end
end
