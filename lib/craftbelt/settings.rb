require 'brock'

module Craftbelt
  class Settings
    attr_reader :schema, :values

    def initialize(definitions, values={})
      @schema = Brock::Schema.new(definitions)
      @values = values
    end

    def field(name)
      field = schema.fields.find{|f| f.name.to_sym == name.to_sym }

      value = values[name]
      if value.nil? 
        value = values[name.to_sym]
      end

      raise "Unknown field: #{name}" if field.nil? and value.nil?

      if field
        if value.nil?
          field.default
        else
          field.parse_param(value)
        end
      else
        value
      end
    end
  end
end