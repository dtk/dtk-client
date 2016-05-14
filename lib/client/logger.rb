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
##
# DtkLogger singleton to be used for logging.
#
require 'singleton'
require 'logger'
require 'colorize'
require 'pp'

module DTK::Client
  class Logger

    LOG_FILE_NAME           = 'client.log'
    LOG_MB_SIZE             = 2
    LOG_NUMBER_OF_OLD_FILES = 10
    
    include Singleton
    
    def initialize
      log_location_dir = log_dir
      begin
        if File.directory?(log_location_dir)
          file = File.open(log_file_path, 'a')
          file.sync = true
          @logger = ::Logger.new(file, LOG_NUMBER_OF_OLD_FILES, LOG_MB_SIZE * 1024000)
          
          @logger.formatter = proc do |severity, datetime, progname, msg|
            "[#{datetime}] #{severity} -- : #{msg}\n"
          end
        else
          no_log_dir(log_location_dir)
        end
      rescue Errno::EACCES
        no_log_permissions(log_location_dir)
      end
    end
    
    LoggerMethods = [:debug, :info, :warn, :error, :fatal, :error_pp, :fatal_pp]
    def self.method_missing(method, *args)
      if LoggerMethods.include?(method)
        instance.send(method, *args)
      else
        super(method, *args)
      end
    end
    
    def self.respond_to?(method)
      LoggerMethods.include?(method) or super(method)
    end
    
    def debug(log_text, sttdout_out=false)
      puts log_text if sttdout_out || development_mode?
      @logger.debug(log_text) if log_created?
    end
    
    def info(log_text, sttdout_out=false)
      puts log_text if sttdout_out || development_mode?
      @logger.info(log_text) if log_created?
    end
    
    def warn(log_text, sttdout_out=false)
      OsUtil.print(log_text, :yellow) if sttdout_out || development_mode?
      @logger.warn(log_text) if log_created?
    end
    
    def error(log_text, sttdout_out=false)
      OsUtil.print(log_text, :red) if sttdout_out || development_mode?
      @logger.error(log_text) if log_created?
    end
    
    def error_pp(message, backtrace, sttdout_out = true)
      error(message, sttdout_out)
      # we do not print this to STDOUT (will be overriden with development_mode?)s
      error("#{message}\n" + PP.pp(backtrace, ""), false) if backtrace
    end
    
    def fatal_pp(message, backtrace, sttdout_out = true)
      fatal(message, sttdout_out)
      # we do not print this to STDOUT (will be overriden with development_mode?)
      fatal("#{message}\n" + PP.pp(backtrace, ""), false) if backtrace
    end
    
    
    def fatal(log_text, sttdout_out=false)
      puts log_text if sttdout_out || development_mode?
      @logger.fatal(log_text) if log_created?
    end
    
    private

    def log_dir
      DtkPath.log_dir
    end

    def log_file_path
      "#{log_dir}/#{LOG_FILE_NAME}"
    end

    def development_mode?
      unless @development_mode.nil?
        @development_mode
      else
        @development_mode = !!Config[:development_mode]
      end
    end

    def log_created?
      #no log found if @logger.nil?
      return !@logger.nil?
    end
    
    def no_log_dir(dir)
      puts "[WARNING] Log directory (#{dir}) does not exist; please add it manually or re-install DTK client."
    end
    
    def no_log_permissions(dir)
      puts "[WARNING] User (#{::DTK::Common::Aux.running_process_user}) does not have permissions to create a log file in log directory (#{dir})"
    end
  end
end
