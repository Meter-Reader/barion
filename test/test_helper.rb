# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'barion'

require 'minitest/autorun'


def rnd_str(length, multiple)
  str = ''
  multiple.times do
    str += ('A'..'Z').to_a.sample(length).join
  end
  str
end
