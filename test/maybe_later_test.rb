require "test_helper"
require "rack"

class MaybeLaterTest < Minitest::Test
  def setup
    MaybeLater.config do |config|
      config.after_each = nil
      config.on_error = nil
      config.inline_by_default = false
      config.max_threads = 5
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
      config.after_each = -> {
        call_count += 1
      }
      config.on_error = ->(e) {
        errors_encountered << e
      }
    end

    MaybeLater.run { chores << :laundry }
    callback_that_will_error = -> { raise "a stink" }
    MaybeLater.run(&callback_that_will_error)
    MaybeLater.run { chores << :tidy }

    _, headers, _ = invoke_middleware!
    assert_equal 0, call_count # <-- nothing could have happened yet!
    sleep 0.01 # <- let threads do stuff

    assert_includes chores, :laundry
    assert_includes chores, :tidy
    assert_equal 3, call_count
    assert_equal 1, errors_encountered.size
    error = errors_encountered.first
    assert_equal "a stink", error.message
    assert_nil headers["Connection"] # No inline runs
  end

  def test_inline_runs
    called = false
    MaybeLater.run(inline: true) { called = true }

    _, headers, _ = invoke_middleware!

    assert called
    assert_equal "close", headers["Connection"]
  end

  def test_inline_by_default
    MaybeLater.config.inline_by_default = true
    called = false
    MaybeLater.run { called = true }

    invoke_middleware!

    assert called
  end

  def test_inline_by_default_still_allows_async
    MaybeLater.config.inline_by_default = true
    called = false
    MaybeLater.run(inline: false) { called = true }

    invoke_middleware!

    refute called # unpossible if async!
  end

  def test_only_callsback_once
    call_count = 0
    MaybeLater.run { call_count += 1 }

    invoke_middleware!
    invoke_middleware!
    invoke_middleware!
    invoke_middleware!
    sleep 0.01 # <- let threads do stuff

    assert_equal 1, call_count
  end

  def test_that_a_callable_is_required
    e = assert_raises { MaybeLater.run }

    assert_kind_of MaybeLater::Error, e
    assert_equal "No block was passed to MaybeLater.run", e.message
  end

  private

  def invoke_middleware!
    env = Rack::MockRequest.env_for
    subject = MaybeLater::Middleware.new(->(env) { [200, {}, "success"] })
    result = subject.call(env)

    # The server will do this
    env[MaybeLater::Middleware::RACK_AFTER_REPLY]&.first&.call

    result
  end
end
