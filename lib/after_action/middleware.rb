module AfterAction
  class Middleware
    RACK_AFTER_REPLY = "rack.after_reply"

    def initialize(app)
      @app = app
    end

    def call(env)
      env[RACK_AFTER_REPLY] ||= []
      env[RACK_AFTER_REPLY] << -> { RunsCallbacks.new.call }
      @app.call(env)
    end
  end
end
