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
  module TaskStatusMixin
    def task_status_aux(mode, object_id, object_type, opts = {})
      case mode
        when :refresh
          TaskStatus::RefreshMode.new(mode, object_id, object_type).task_status(opts)
        when :snapshot 
          TaskStatus::SnapshotMode.new(mode, object_id, object_type).task_status(opts)
        when :stream
          TaskStatus::StreamMode.new(mode, object_id, object_type).get_and_render(opts)
        else
          legal_modes = [:refresh, :snapshot, :stream]
          raise Error::Usage.new("Illegal mode '#{mode}'; legal modes are: #{legal_modes.join(', ')}")
      end
    end
  end

  class TaskStatus
    require File.expand_path('task_status/snapshot_mode', File.dirname(__FILE__))
    require File.expand_path('task_status/refresh_mode', File.dirname(__FILE__))
    require File.expand_path('task_status/stream_mode', File.dirname(__FILE__))

    def initialize(mode, object_id, object_type)
      @mode        = mode
      @object_id   = object_id
      @object_type = object_type
    end

    private

    def post_body(opts = {})
      PostBody.new(
        :service_instance       => @object_id,
        :form?                  => opts[:form],
        :wait_for?              => opts[:wait_for],
        :summarize_node_groups? => opts[:summarize]
     )
    end

    def post_call(opts = {})
      Operation.rest_post("#{@object_type}/task_status", post_body(opts))
    end

  end
end
