# frozen_string_literal: true

module Barion
  # Barion specific validations
  module Validations
    def truncate(str, limit)
      return str.to_s[0..limit - 1] unless limit < 2

      str
    end

    def validate_size(name, value, min: nil, max: nil)
      raise ArgumentError, "#{value} is not numeric" unless value.is_a?(Numeric)

      raise ArgumentError, "#{value} is too small for #{name}" if !min.nil? && value < min

      raise ArgumentError, "#{value} is too big for #{name}" if !max.nil? && value > max

      value
    end

    def validate_length(name, value, min: nil, max: nil, truncate: false)
      raise ArgumentError, "#{value} is not string" unless value.is_a?(String)

      raise ArgumentError, "#{value} is too short for #{name}" if !min.nil? && value.to_s.length < min

      unless max.nil?
        raise ArgumentError, "#{value} is too long for #{name}" if value.to_s.length > max && !truncate

        return truncate(value, max)
      end
      value
    end

    def format_phone_number(number)
      number = number.sub(/^\+/, '').sub(/^00/, '')
      validate_length('phone number', number, max: 30)
    end
  end
end
