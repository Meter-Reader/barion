# frozen_string_literal: true

module Barion
  # Common data formats in Barion
  module DataFormats
    extend ActiveSupport::Concern

    def self.phone_number(number)
      number.sub(/^\+/, '').sub(/^00/, '')[0..29]
    end

    def self.as_time(sec)
      day, sec = sec.divmod(1.days)
      hour, sec = sec.divmod(1.hour)
      min, sec = sec.divmod(1.minute)
      format('%<day>d.%02<hour>d:%02<min>d:%02<sec>d', day: day, hour: hour, min: min, sec: sec)
    end

    def self.as_datetime(date)
      date.delete_suffix('Z')
    end
  end
end
