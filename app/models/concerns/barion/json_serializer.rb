# frozen_string_literal: true

module Barion
  # JSON serialization solution for Barion
  module JsonSerializer
    extend ActiveSupport::Concern

    def json_options
      {}
    end

    def as_json(options = {})
      result = super(json_options.merge(options))
      if json_options.key?(:map)
        if json_options[:map].key?(:keys)
          convert_keys(result, json_options[:map][:keys], &json_options[:map][:keys][:_all])
        end
        if json_options[:map].key?(:values)
          convert_values(result, json_options[:map][:values], &json_options[:map][:values][:_all])
        end
      end
      result
    end

    private

    def convert_keys(hash, map, &block)
      hash.transform_keys!(&block) if block_given?
      hash.transform_keys! { |k| map.fetch(k.to_sym, k) unless k.nil? }
    end

    def convert_values(hash, map, &block)
      hash_exceptions = hash.slice(*map[:_except])
      hash.transform_values!(&block) if block_given?
      hash.merge!(hash_exceptions)
      hash.each do |k, v|
        ks = k.to_sym
        if v.present? && map.key?(ks) && Barion::DataFormats.respond_to?(map[ks])
          hash[k] = Barion::DataFormats.__send__(map[ks], v)
        end
      end
    end
  end
end
