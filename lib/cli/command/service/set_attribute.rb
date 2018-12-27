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
module DTK::Client; module CLI
  module Command
    module Service
      subcommand_def 'set-attribute' do |c|
        c.arg Token::Arg.attribute_name, :optional => true
        c.arg Token::Arg.attribute_value, :optional => true
        command_body c, 'set-attribute',  'Set attribute value(s).' do |sc|
          sc.switch Token.u
          sc.flag Token.directory_path
          sc.flag Token.param_file
          sc.action do |_global_options, options, args|
            service_instance     = service_instance_in_options_or_context(options)
            service_instance_dir = options[:d] || @base_dsl_file_obj.parent_dir

            helper = SetAttributeHelper.new(service_instance, service_instance_dir)

            attribute_name = args[0]
            # if attribute_name not given then expected that a YAML file is given that has attribute values
            unless attribute_name
              name_value_pairs = helper.get_name_value_pairs_from_yaml_file(options)
              # TODO: should extend the server-side to take list of attributes to set; hack to return a value ret
              name_value_pairs.each_pair do |attribute_name, attribute_value|
                begin
                  helper.set_single_attribute(attribute_name, attribute_value)
                rescue Error 
                  raise Error::Usage, "Error trying to set attribute '#{attribute_name}' from YAML file"
                end
              end
              nil
            else
              attribute_value = 
                unless options[:u]
                  if ruby_obj_value = helper.get_yaml_from_file?(options)
                    ::JSON.generate(ruby_obj_value)
                  else
                    args[1] || raise(Error::Usage, "Either argument VALUE or -f option must be given to specify a value")
                  end
                end
              helper.set_single_attribute(attribute_name, attribute_value)
            end
          end
        end
      end

      class SetAttributeHelper
        def initialize(service_instance, service_instance_dir)
          @service_instance     = service_instance
          @service_instance_dir = service_instance_dir
        end

        def set_single_attribute(attribute_name, attribute_value)
          Operation::Service.set_attribute(
            :attribute_name   => attribute_name,
            :attribute_value  => attribute_value,
            :service_instance => self.service_instance,
            :service_instance_dir => self.service_instance_dir
          )
        end

        def get_yaml_from_file?(cli_options)
          if param_file_path = cli_options[:f]
            param_file = check_and_return_file_content(param_file_path)
            yaml_to_ruby_obj(param_file, param_file_path)
          end
        end

        def get_name_value_pairs_from_yaml_file(options)
          unless ruby_obj = get_yaml_from_file?(options)
            raise Error::Usage, "If NAME argument is not given then -f option must be given to specify a value"
          end

          # check that gile is form
          #attributes:
          # name1: val1
          # ...
          unless ruby_obj.kind_of?(::Hash) and ruby_obj.size == 1 and ruby_obj.keys.first == 'attributes'
            raise Error::Usage, "If NAME argument is not given, the parameter file content must be YAML hash starting with key 'attributes'"
          end
          name_value_pairs = ruby_obj['attributes']
          unless name_value_pairs.kind_of?(::Hash)
            raise Error::Usage, "If NAME argument is not given, the parameter file content must be YAML hash with name/attribute values"
          end
          name_value_pairs.inject({}) { |h, (k, v)| h.merge(k => ::JSON.generate(v)) }
        end

        private
        
        def check_and_return_file_content(path)
          raise Error::Usage, "The file at path '#{path}' does not exist" unless File.file?(path)
          File.open(path).read
        end

        def yaml_to_ruby_obj(text, path)
          begin
            ::YAML.load(text)
          rescue
            raise Error::Usage, "Content in file '#{path}' is ill-formed YAML"
          end
        end

        protected

        attr_reader :service_instance, :service_instance_dir

      end

    end
  end
end; end
