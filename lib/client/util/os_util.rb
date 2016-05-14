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
  module OsUtil
    require_relative('os_util/print')
    require_relative('os_util/location')

    extend PrintMixin
    extend LocationMixin

    extend Auxiliary
    
    class << self
      def current_dir
        current_dir = Dir.getwd
        current_dir.gsub(home_dir, '~')
      end
      
      def get_temp_location
        is_windows? ? genv(:temp) : '/tmp'
      end
      
      def genv(name)
        ENV[name.to_s.upcase].gsub(/\\/,'/')
      end
      
      def which(cmd)
        exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
        ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
          exts.each { |ext|
          exe = File.join(path, "#{cmd}#{ext}")
            return exe if File.executable? exe
          }
        end
        nil
      end
      
      private
      
      def home_dir
        is_windows? ? "#{genv(:homedrive)}#{genv(:homepath)}" : "#{genv(:home)}"
      end
      
      def is_mac?
        RUBY_PLATFORM.downcase.include?('darwin')
      end
      
      def is_windows?
        RUBY_PLATFORM =~ /mswin|mingw|cygwin/
      end
      
      def is_linux?
        RUBY_PLATFORM.downcase.include?('linux')
      end
    end
  end
end
