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
  module CLI::Command
    ##
    # Common terms used in commands
    class Token < ::Hash
      require_relative('token/mixin')
      require_relative('token/class_mixin')
      require_relative('token/flag')
      require_relative('token/switch')
      require_relative('token/arg')

      include Mixin
      extend ClassMixin
      
      TOKENS = {
        # flags
        # Flag constructor args order: key, arg_name, desc, opts={}
        :commit_message          => Flag.new(:m, 'COMMIT-MSG', 'Commit message'),
        :directory_path          => Flag.new(:d, 'DIRECTORY-PATH', 'Directory path'),
        :parent_service_instance => Flag.new(:parent, 'PARENT', 'Parent service instance; if not specfied, the default target service instance serves as parent'),
        :module_ref   => Flag.new(:m, ModuleRef::NamespaceModuleName.legal_form, 'Module name with namespace; not needed if command is executed from within the module directory'),
        :relative_path           => Flag.new(:f, 'RELATIVE-PATH', 'Relative path'),

        :service_instance        => Flag.new(:s, 'SERVICE-INSTANCE', 'Service instance name'),
        :service_name            => Flag.new(:n, 'SERVICE-NAME', 'Service name'),
        :version                 => Flag.new(:v, 'VERSION', 'Version'),

        # switches
        # Switch constructor args order: key, desc, opts={}
        :all         => Switch.new(:all, 'All'),
        :force       => Switch.new(:f, 'Force'),
        :purge       => Switch.new(:purge, 'Purge'),
        :push        => Switch.new(:push, 'Push changes'),
        :skip_prompt => Switch.new(:y, 'Skip prompt'),
        :target      => Switch.new(:target, 'Create target service instance'),
      }

      ARG_TOKENS = {
        :assembly_name    => 'ASSEMBLY-NAME',
        :service_instance => flag_token(:service_instance).arg_name,  
      }
      
    end
  end
end
