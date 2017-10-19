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
module DTK::Client; class Operation::Service::TaskStatus::StreamMode
  class Element
    require_relative('element/format')
    require_relative('element/render')
    require_relative('element/hierarchical_task')
    require_relative('element/task_start')
    require_relative('element/task_end')
    require_relative('element/stage')
    require_relative('element/no_results')
    include RenderMixin

    def initialize(response_element, opts = {})
      @response_element        = response_element
      @formatter               = Format.new(response_element['type'])
      @ignore_stage_level_info = opts[:ignore_stage_level_info]
    end

    def self.get_and_render_task_start(task_status_handle, opts = {})
      render_elements(TaskStart.get(task_status_handle, opts))
    end

    def self.get_and_render_stages(task_status_handle, opts = {})
      Stage.get_and_render_stages(task_status_handle, opts)
    end

    private

    # opts will have
    #   :start_index
    #   :end_index
    # opts can have
    #   :ignore_stage_level_info - Boolean
    def self.get_task_status_elements(task_status_handle, element_type, opts = {})
      response =  task_status_handle.rest_call(opts.merge(:form => :stream_form))
      create_elements(response, opts)
    end

    # opts can have
    #   :ignore_stage_level_info - Boolean
    def self.create_elements(response, opts = {})
      response_elements = response.data      
      unless response_elements.kind_of?(Array)
        raise Error.new("Unexpected that response.data no at array")
      end
      response_elements.map { |el| create(el, opts) }
    end
    def self.create(response_element, opts)
      type = response_element['type'] 
      case type && type.to_sym
        when :task_start  then TaskStart.new(response_element, opts)
        when :task_end    then TaskEnd.new(response_element, opts)
        when :stage       then Stage.new(response_element, opts)
        when :stage_start then Stage.new(response_element, {:just_render => :start}.merge(opts))
        when :stage_end   then Stage.new(response_element, {:just_render => :end}.merge(opts))
        when :no_results  then NoResults.new(response_element, opts)
        else              raise Error.new("Unexpected element type '#{type}'")
      end
    end
    
    def self.task_end?(elements)
      elements.empty? or elements.last.kind_of?(TaskEnd)
    end
    
    def self.no_results_yet?(elements)
      elements.find{|el|el.kind_of?(NoResults)}
    end

    def self.debug_mode?(response)
      debug_mode_rows(response).size > 0
    end

    def self.debug_mode_rows(response)
      response['data'].select do |data_row|
        data_row['status'] == 'debugging'
      end
      #{ |data_row| data_row['status'] == 'debugging' }
    end

    def self.add_info_if_debug_mode!(response)
      debug_info_rows = debug_mode_rows(response).select { |row| (row['info'] || {}) }
      if debug_info_rows.size > 0
        info_message = debug_info_rows.last['info']['message']
        #response.set_render_as_table!(nil, info_message)
      else
        #response.set_render_as_table!
      end
    end

    def self.render_elements(elements)
      elements.each do |el| #{ |el| el.render }
        el.render
      end
    end

    def render_stage_steps(subtasks)
      HierarchicalTask.render_steps(self, subtasks)
    end

    def render_stage_results(subtasks)
      HierarchicalTask.render_results(self, subtasks)
    end

    def field?(field)
      @response_element[field.to_s]
    end
  end
end; end
