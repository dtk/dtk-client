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
module DTK::Client; class Operation::Service::TaskStatus::StreamMode::Element
  class HierarchicalTask 
    class Results < self
      require_relative('result/action')
      require_relative('result/components')
      require_relative('result/node_level')

      def initialize(element, hash)
        super
        @errors = hash['errors'] || []
        @info = hash['info'] || []
        @action_results = hash['action_results'] || []
      end

      # This can be over-written
      def action_results
        []
      end

      def self.render(element, stage_subtasks)
        results_per_node = base_subtasks(element, stage_subtasks)
        return if results_per_node.empty?
        # assumption is that if multipe results_per_node they are same type
        results_per_node.first.render_results(results_per_node)
      end

      protected 

      attr_reader :errors
      attr_reader :info
      attr_reader :action_results

      def render_errors(results_per_node)
        return unless results_per_node.find do |result|  
          not result.errors.empty?
        end
        first_time = true
        results_per_node.each do |result| 
          if first_time
            render_line 'ERRORS:' 
            first_time = false
          end
          result.render_node_errors  
        end
      end

      def render_info(results_per_node)
        return unless results_per_node.find do |result|
          not result.info.empty? and result.errors.empty? 
        end
        # { |result| not result.errors.empty?}
        first_time = true
        results_per_node.each do |result|
          if first_time
            render_line 'INFO:'
            first_time = false
          end
          result.render_node_info
        end
      end

      def render_output(results_per_node)
        return unless results_per_node.find do |result|
          not result.action_results.empty?
        end
        first_time = true
        results_per_node.each do |result|
          if first_time
            render_line 'OUTPUT:'
            first_time = false
          end
          result.render_node_output
        end
      end

      def render_node_errors
        return if @errors.empty?
        render_node_term
        @errors.each do |error| 
          if err_msg = error['message']
            render_error_line err_msg
            render_empty_line
          end
        end
      end

      def render_node_info
        return if @info.empty? || !@errors.empty?
        @info.each do |info| 
          if err_msg = info[1]
            #err_msg.colorize(:yellow)
            render_info_line err_msg
            render_empty_line
          end
        end
      end

      def render_node_output
        return if @action_results.empty?
        @action_results.each do |output|
          if dynamic_attrs = output['dynamic_attributes']
            render_dynamic_attrs(dynamic_attrs)
          end
        end
      end

      def render_dynamic_attrs(dynamic_attrs)
        dynamic_attrs.each do |name, opts|
          next unless opts['value'] 
          out = opts['value']

          if disp_form = opts['display_format']
            out = 
              case disp_form
              when 'yaml'
                out.to_yaml
              when 'json'
                out.to_json
              end
          end
          render_output_line(name + ':', out)
          render_empty_line
        end
      end

      def render_error_line(line, opts = {})
        render_line(line, ErrorRenderOpts.merge(opts))
      end

      def render_info_line(line, opts = {})
        render_line(line)
      end

      def render_output_line(attr_name, attr_value)
        render_line attr_name, RenderAttrNameOpts
        render_line attr_value, RenderAttrValOpts
      end
      ErrorRenderOpts = { :tabs => 1 }
      RenderAttrNameOpts = { :tabs => 1 }
      RenderAttrValOpts = { :tabs => 2 }

    end
  end
end; end
