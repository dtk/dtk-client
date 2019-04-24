module DTK::Client
  class CustomResource
    class Crd < self
      # attr_reader :parsed_common_module

      def transform_info
        transform_to_component_info
      end

      private

      def self.info_type
        :kubernetes_crd
      end

      def transform_to_component_info
        info_processor.read_inputs_and_compute_outputs!
        # info_processor.file_path__content_array
      end
    end
  end
end