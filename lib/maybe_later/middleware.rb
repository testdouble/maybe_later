module MaybeLater
  class Middleware
    RACK_AFTER_REPLY = "rack.after_reply"

    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)
      if Store.instance.callbacks.any?
        env[RACK_AFTER_REPLY] ||= []
        env[RACK_AFTER_REPLY] << -> {
          RunsCallbacks.new.call
        }
        if Store.instance.callbacks.any? { |cb| cb.inline }
          headers["Connection"] = "close"
        end
      end
      [status, headers, body]
    end
  end
end
