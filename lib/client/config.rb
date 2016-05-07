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
require 'singleton'

module DTK::Client
  ##
  # Singleton patern to hold configuration for dtk client.
  #
  class Config < Hash
    include Singleton
    
    def self.[](k)
      instance.get(k)
    end

    private

    def initialize
      set_defaults!
      load_config_file_values!
      validate
    end

    CLIENT_CONF            = 'client.conf'
    DEFAULT_CONF_FILE_PATH = File.expand_path('config/default.conf', File.dirname(__FILE__))

    def set_defaults!
      merge_config_file_content_into_hash!(DEFAULT_CONF_FILE_PATH)
    end
    
    def load_config_file_values!
      client_config_path = Configurator.client_config_path
      merge_config_file_content_into_hash!(client_config_path) if File.exist?(client_config_path)
    end

    REQUIRED_KEYS = [:server_host]
    def validate
      #TODO: need to check for legal values
      missing_keys = REQUIRED_KEYS - keys
      raise DtkError, "Missing config keys (#{missing_keys.join(",")}). Please check your configuration file #{Configurator.client_config_path} for required keys!" unless missing_keys.empty?
    end

    def get(name)
      self[name.to_s]
    end

    def merge_config_file_content_into_hash!(path)
x=      parse_string_content(File.read(path))
pp x
x
    end

    # returns a hash
    def parse_string_content(string)
      ret = {}
      string.each_line do |line|
        line.strip!
        if line =~ /(^[^=]+)=(.+$)/
          attr = $1
          val_string = $2
          ret.merge!(attr => parse_value_string(val_string))
        else
          raise DtkError, "Parse error in config file '#{Configurator.client_config_path}' following line is ill-formed:\n  #{line}\n"
        end
      end
      ret
    end

    def parse_value_string(val_string)
      # strip off comment
      ret = val_string.gsub(/#.+$/,'')
      # remove control characters and leading blanks
      ret = ret.gsub(/(\r|\t)/,'')
      ret.gsub(/^[ ]+/,'')
    end

    def convert_data_types(val_string)
      case val_string
       when /^(true|false)$/ 
        val_string.eql?('true') ? true : false
       when /^[0-9]+$/
        val_string.to_i
       when /^[0-9\.]+$/
        val_string.to_f
       else 
        val_string
      end
    end
  end
end
