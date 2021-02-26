# frozen_string_literal: true

module Barion
  # JSON serialization solution for Barion
  module JsonSerializer
    extend ActiveSupport::Concern

    def json_options
      {}
    end

    def as_json(options = {})
      result = super(json_options.merge(options)).deep_transform_keys!(&:camelize)
      if json_options.key?(:map)
        convert_keys(result, json_options[:map][:keys]) if json_options[:map].key?(:keys)
        json_options[:map][:values].merge(result) if json_options[:map].key?(:values)
      end
      # result.compact!
      result
    end

    def convert_keys(hash, map)
      hash.transform_keys! { |k| map.fetch(k.to_sym, k) unless k.nil? }
    end
  end
end
