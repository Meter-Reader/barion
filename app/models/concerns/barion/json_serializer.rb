# frozen_string_literal: true

module Barion
  # JSON serialization solution for Barion
  module JsonSerializer
    extend ActiveSupport::Concern

    def serialize_options
      {}
    end

    def deserialize_options
      {}
    end

    def key_names
      {}
    end

    def serializable_hash(options = {})
      options ||= serialize_options
      result = super(serialize_options.merge(options))
      if serialize_options.key?(:map)
        if serialize_options[:map].key?(:values)
          convert_values(result, serialize_options[:map][:values], &serialize_options[:map][:values][:_all])
        end
        if serialize_options[:map].key?(:keys)
          convert_keys(result, serialize_options[:map][:keys], &serialize_options[:map][:keys][:_all])
        end
      end
      result.compact!
    end

    def deserialize(hash, options = {})
      options ||= deserialize_options
      deserialize_options.merge(options)
      return unless deserialize_options.key?(:map)

      if deserialize_options[:map].key?(:values)
        convert_values(hash, deserialize_options[:map][:values], &deserialize_options[:map][:values][:_all])
      end
      return unless deserialize_options[:map].key?(:keys)

      convert_keys(hash, deserialize_options[:map][:keys], &deserialize_options[:map][:keys][:_all])
    end

    def process_response(response)
      hash = deserialize(response)
      hash.map do |key, value|
        association = self.class.reflect_on_association(key)
        if association
          (model_key_name, key_name) = deserialize_options[:assoc][key.to_sym].shift if deserialize_options.key?(:assoc)
          value.each do |params|
            id = params[key_name]
            item = association.klass.send("find_by_#{model_key_name}", id)
            item.send(:process_response, params.compact!)
          end
        elsif respond_to?("#{key}=")
          send("#{key}=", value)
        end
      end
    end

    private

    def convert_keys(hash, map, &block)
      hash.transform_keys! { |k| map.fetch(k.to_sym, k) unless k.nil? }
      hash.transform_keys!(&block) if block_given?
    end

    def convert_values(hash, map, &block)
      hash.each do |k, v|
        ks = k.to_sym
        hash[k] = send(map[ks], ks, v) if v.present? && map.key?(ks) && respond_to?(map[ks], true)
      end
      hash_exceptions = hash.slice(*map[:_except])
      hash.transform_values!(&block) if block_given?
      hash.merge!(hash_exceptions)
    end

    def as_time(_, sec)
      day, sec = sec.divmod(1.days)
      hour, sec = sec.divmod(1.hour)
      min, sec = sec.divmod(1.minute)
      format('%<day>d.%02<hour>d:%02<min>d:%02<sec>d', day: day, hour: hour, min: min, sec: sec)
    end

    def as_datetime(_, date)
      date.as_json.delete_suffix('Z')
    end

    def as_list(_, string)
      string.camelize.split(',')
    end

    def as_enum_id(enum, id)
      hash = self.class.send(enum.to_s.pluralize)
      hash.fetch(id)
    end

    def as_string(_, value)
      value.to_s
    end
  end
end
