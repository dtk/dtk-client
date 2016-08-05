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
  class OsUtil
    require 'readline'
    require_relative('os_util/print')
    extend Auxiliary
    extend PrintMixin
    
    def self.home_dir
      is_windows? ? home_dir__windows : genv(:home)
    end
    
    DTK_FOLDER_DIR = 'dtk'
    def self.dtk_local_folder
      "#{home_dir}/#{DTK_FOLDER_DIR}"
    end
    
    def self.temp_dir
      is_windows? ? genv(:temp) : '/tmp'
    end

    def self.current_dir
      Dir.getwd
    end
    
    def self.which(cmd)
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each { |ext|
          exe = File.join(path, "#{cmd}#{ext}")
          return exe if File.executable? exe
        }
      end
      nil
    end

    def self.parent_dir(path)
      parent_dir?(path) || raise(Error::Usage, "Cannot find parent directory of '#{path}'")
    end

    # Returns parent directory; if at root returns nil
    def self.parent_dir?(path)
      raise Error.new("Not implemented for windows") if is_windows?
      ret = File.expand_path('../', path)
      unless ret == path # meaning at root
        ret
      end
    end

    def self.delim
      is_windows? ? '\\' : '/'
    end

    def self.edit(file)
      editor = ENV['EDITOR']
      if is_windows?
        raise Client::DtkError, "Environment variable EDITOR needs to be set; exit dtk-shell, set variable and log back into dtk-shell." unless editor
      else
        editor = 'vim' unless editor
      end

      system("#{editor} #{file}")
    end

    def self.user_input(message)
      trap("INT", "SIG_IGN")
      while line = Readline.readline("#{message}: ",true)
        unless line.chomp.empty?
          trap("INT", false)
          return line
        end
      end
    end

    DTK_IDENTITY_FILE = 'dtk.pem'
    def self.dtk_identity_file_location
      path_to_identity_file = "#{dtk_local_folder}/#{DTK_IDENTITY_FILE}"
      return path_to_identity_file if File.exists?(path_to_identity_file)
      print_warning("TIP: You can save your identity file as '#{path_to_identity_file}' and it will be used as default identityfile.")
      nil
    end

    private
    
    def self.genv(name)
      ENV[name.to_s.upcase].gsub(/\\/,'/')
    end
    
    def self.is_mac?
      RUBY_PLATFORM.downcase.include?('darwin')
    end
    
    def self.is_windows?
      RUBY_PLATFORM =~ /mswin|mingw|cygwin/
    end
    
    def self.home_dir__windows
      "#{genv(:homedrive)}#{genv(:homepath)}"
    end
    
    def self.is_linux?
      RUBY_PLATFORM.downcase.include?('linux')
    end
  end
end

