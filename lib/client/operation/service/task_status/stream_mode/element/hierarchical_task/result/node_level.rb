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
module DTK::Client; class Operation::Service::TaskStatus::StreamMode::Element::HierarchicalTask
  class Results
    class NodeLevel < self
      def render
        not_first_time = nil
        render_node_term
        @action_results.each do |action_result| 
          render_action_result_lines(action_result, :first_time => not_first_time.nil?) 
          not_first_time ||= true
        end
        render_empty_line
      end

      def render_results(results_per_node)
        render_errors(results_per_node)
      end
    end
  end
end; end
