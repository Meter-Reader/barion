# frozen_string_literal: true

require 'test_helper'

require 'barion/environment'

# Barion configuration expected behaviour
class EnvironmentTest < Minitest::Test
  def test_environment_is_threadsafe_singleton
    io, err = capture_subprocess_io do
      process1 = Thread.new { puts Barion::Environment.test }
      process2 = Thread.new { puts Barion::Environment.test }
      process1.join
      process2.join
    end
    lines = io.lines.map(&:chomp)
    assert_equal lines[0], lines[1]
    assert_empty err
  end

  def test_getting_test_environment
    env = Barion::Environment.test
    assert_kind_of Barion::Environment, env
    assert_equal Barion::Environment::BASE_URL[:test], env.base_url
  end

  def test_getting_production_environment
    env = Barion::Environment.production
    assert_kind_of Barion::Environment, env
    assert_equal Barion::Environment::BASE_URL[:prod], env.base_url
  end

  def test_cannot_be_instantiated_directly
    assert_raises NoMethodError do
      Barion::Environment.new
    end
    assert_raises NoMethodError do
      Barion::TestEnvironment.new
    end
    assert_raises NoMethodError do
      Barion::ProductionEnvironment.new
    end
  end

  def test_sandbox_is_test_environment
    test_env = Barion::Environment.test
    sandbox_env = Barion::Environment.sandbox
    assert_equal test_env, sandbox_env
  end

  def test_base_url_exists
    test_env = Barion::Environment.test
    prod_env = Barion::Environment.production
    assert_respond_to test_env, 'base_url'
    assert_respond_to prod_env, 'base_url'
  end

  def test_base_url_protected
    env = Barion::Environment.production
    assert_raises NoMethodError do
      env.base_url = 'http://example.com'
    end
  end
end
