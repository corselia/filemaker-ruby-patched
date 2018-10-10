module Filemaker
  module Model
    module Builder
      module_function

      # Given an array of resultset, build out the exact same number of model
      # objects.
      def collection(resultset, klass)
        models = []

        resultset.each do |record|
          models << build(record, klass.new)
        end

        models
      end

      def build(record, object)
        object.instance_variable_set('@new_record', false)
        object.instance_variable_set('@record_id', record.record_id)
        object.instance_variable_set('@mod_id', record.mod_id)
        object.instance_variable_set('@portals', record.portals)

        record.each_key do |fm_field_name|
          # record.keys are all lowercase
          field = object.class.find_field_by_name(fm_field_name)

          # Do not bother with undefined field, we don't necessarily need all
          # FM's fields
          next unless field

          setter = :"#{field.name}="
          value = field.cast(record[fm_field_name])
          object.public_send(setter, value)

          # So after hydrating, we do not say it was dirty
          object.clear_changes_information
        end

        object
      end
    end
  end
end
