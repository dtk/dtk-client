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
        :commit_message            => Flag.new(:m, 'COMMIT-MSG', 'Commit message'),
        :directory_path            => Flag.new(:d, 'DIRECTORY-PATH', 'Directory path'),
        :comma_seperated_contexts  => Flag.new(:context, 'CONTEXT1,CONTEXT2,...' ,'Comma-seperated context service instance(s); if not specified, the default service instance serves as the context'),
        :module_ref                => Flag.new(:m, ModuleRef::NamespaceModuleName.legal_form, 'Module name with namespace; not needed if command is executed from within the module directory'),
        :relative_path             => Flag.new(:f, 'RELATIVE-FILE-PATH', 'Relative file path'),
        :service_instance          => Flag.new(:s, 'SERVICE-INSTANCE', 'Service instance name'),
        :service_name              => Flag.new(:n, 'SERVICE-NAME', 'Service name'),
        :version                   => Flag.new(:v, 'VERSION', 'Version'),
        :type                      => Flag.new(:type, 'TYPE', 'Type'),
        :node                      => Flag.new(:n, 'NODE', 'Node'),
        :component                 => Flag.new(:c, 'COMPONENT', 'Component'),
        :remote_user               => Flag.new(:u, 'REMOTE-USER', 'Remote user'),
        :identity_file             => Flag.new(:i, 'PATH-TO-PEM', 'Path to pem file'),
        :mode                      => Flag.new(:mode, 'MODE', 'Mode'),
        :namespace                 => Flag.new(:n, 'NAMESPACE', 'Namespace'),
        :uninstall_name            => Flag.new(:name, 'NAME', 'Module name to uninstall'),
        :link_name                 => Flag.new([:l, :link_name], 'link-name', 'Specify link name'),
        :format                    => Flag.new(:format, 'FORMAT', 'Choose in which format to display data (ex. TABLE, YAML)'),

        # switches
        # Switch constructor args order: key, desc, opts={}
        :all          => Switch.new(:all, 'All'),
        :base         => Switch.new(:base, 'Create base service instance'),
        :breakpoint       => Switch.new([:b, :breakpoint], 'Add breakpoint'),
        :delete       => Switch.new(:delete, 'Delete'),
        :force        => Switch.new([:f, :force], 'Force'),
        :purge        => Switch.new(:purge, 'Purge'),
        :push         => Switch.new(:push, 'Push changes'),
        :skip_prompt  => Switch.new(:y, 'Skip prompt'),
        :target       => Switch.new(:target, 'Create target service instance'),
        :links        => Switch.new(:links, 'Links'),
        :unlink       => Switch.new([:u, :unlink], 'unlink'),
        :dependencies => Switch.new(:deps, 'Dependencies'),
        :u            => Switch.new([:u, :unset], 'Unset attribute'),
        :recursive    => Switch.new(:r, 'Recursive'),
        :update_deps  => Switch.new('update-deps', "Skip prompt and update all dependencies or skip prompt and don't update all dependencies  (on master)", :negatable => true, :default_value => 'prompt'),
        :update_lock  => Switch.new([:u, 'update-lock'], 'Update lock file with new dependencies')
      }

      ARG_TOKENS = {
        :assembly_name    => 'ASSEMBLY-NAME',
        :service_instance => flag_token(:service_instance).arg_name,
        :node_name        => 'NODE',
        :action           => '[NODE/NODE-GROUP/]ACTION',
        :action_params    => 'ACTION-PARAMS',
        :workspace_name   => 'WORKSPACE-NAME',
        :target_instance  => 'TARGET-SERVICE-INSTANCE',
        :module_name      => 'NAMESPACE/MODULE-NAME',
        :target_directory => 'TARGET-DIRECTORY',
        :attribute_name   => 'ATTRIBUTE-NAME',
        :keypair_name     => 'KEYPAIR-NAME',
        :attribute_value  => 'VALUE',
        :component_ref    => 'COMPONENT-REF',
        :format           => 'FORMAT',
        :base_cmp         => 'BASE-COMPONENT',
        :deps_on_cmp      => 'DEPENDS-ON-COMPONENT',
        :service          => 'SERVICE',
        :service_name     => 'SERVICE-NAME'
      }
      
    end
  end
end
