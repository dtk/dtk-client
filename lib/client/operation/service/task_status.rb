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
    class TaskStatus < self
      require_relative('task_status/snapshot_mode')
      require_relative('task_status/refresh_mode')
      require_relative('task_status/stream_mode')

      def initialize(mode, service_instance)
        @mode             = mode
        @service_instance = service_instance
      end

      def self.execute(args = Args.new)
        wrap_operation(args) do |args|
          service_instance = args.required(:service_instance)
          task_status_mode = args[:mode]
          info             = nil

          task_status_mode ||=  DEFAULT_MODE 
          task_status_with_mode(task_status_mode.to_sym, service_instance)
        end
      end

      def rest_call(opts = {})
        self.class.rest_call(@service_instance, opts)
      end

      private

      DEFAULT_MODE = :snapshot
      LEGAL_MODES  = [:refresh, :snapshot, :stream]
      def self.task_status_with_mode(mode, service_instance, opts = {})
        case mode
        when :refresh
          RefreshMode.new(mode, service_instance).task_status(opts)
        when :snapshot 
          SnapshotMode.new(mode, service_instance).task_status(opts)
        when :stream
          StreamMode.new(mode, service_instance).get_and_render(opts)
        else
          raise Error::Usage.new("Illegal mode '#{mode}'; legal modes are: #{LEGAL_MODES.join(', ')}")
        end
      end
      
      def self.rest_call(service_instance, opts = {})
        rest_get("#{BaseRoute}/#{service_instance}/task_status", query_string_hash(opts))
      end

      def self.query_string_hash(opts = {})
        QueryStringHash.new( 
          :form?                  => opts[:form],
          :wait_for?              => opts[:wait_for],
          :summarize_node_groups? => opts[:summarize]
        )
      end
      
      def add_info_if_debug_mode!(response)
        debug_info_rows = debug_mode_rows(response).select { |row| (row['info'] || {})['message'] }
        if debug_info_rows.size > 0
          info_message = debug_info_rows.last['info']['message']
          response.set_render_as_table!(nil, info_message)
        else
          response.set_render_as_table!
        end
      end
      
      def debug_mode?(response)
        debug_mode_rows(response).size > 0
      end

      def debug_mode_rows(response)
        response['data'].select do |data_row|
           data_row["info"] unless data_row["info"].nil? || data_row["info"].empty?
        end
        # Almin: Add breakpoint and check if this above works better
        #response['data'].select { |data_row| data_row['status'] == 'debugging' }
      end

    end
  end
end
