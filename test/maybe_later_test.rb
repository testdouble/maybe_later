require "test_helper"
require "rack"

class MaybeLaterTest < Minitest::Test
  def setup
    MaybeLater.config do |config|
      config.after_each = nil
      config.on_error = nil
    end
  end

  def test_that_it_has_a_version_number
    refute_nil ::MaybeLater::VERSION
  end

  def test_a_couple_callbacks
    chores = []
    call_count = 0
    errors_encountered = []

    MaybeLater.config do |config|
      config.after_each = -> { call_count += 1 }
      config.on_error = ->(e) {
        errors_encountered << e
      }
    end

    MaybeLater.run { chores << :laundry }
    callback_that_will_error = -> { raise "a stink" }
    MaybeLater.run(&callback_that_will_error)
    MaybeLater.run { chores << :tidy }

    invoke_middleware!

    assert_equal [:laundry, :tidy], chores
    assert_equal 3, call_count
    assert_equal 1, errors_encountered.size
    error = errors_encountered.first
    assert_equal "a stink", error.message
  end

  def test_only_callsback_once
    call_count = 0
    MaybeLater.run { call_count += 1 }

    invoke_middleware!
    invoke_middleware!
    invoke_middleware!
    invoke_middleware!

    assert_equal 1, call_count
  end

  private

  def invoke_middleware!
    env = Rack::MockRequest.env_for
    subject = MaybeLater::Middleware.new(->(env) { [200, {}, "success"] })
    subject.call(env)

    # The server will do this
    env[MaybeLater::Middleware::RACK_AFTER_REPLY].first.call
  end
end
