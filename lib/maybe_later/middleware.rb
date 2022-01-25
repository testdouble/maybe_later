module MaybeLater
  class Middleware
    RACK_AFTER_REPLY = "rack.after_reply"

    def initialize(app)
      @app = app
    end

    def call(env)
      config = MaybeLater.config

      status, headers, body = @app.call(env)
      if Store.instance.callbacks.any?
        if env.key?(RACK_AFTER_REPLY)
          env[RACK_AFTER_REPLY] << -> {
            RunsCallbacks.new.call
          }
        elsif !config.invoke_even_if_server_is_unsupported
          warn <<~MSG
            This server may not support '#{RACK_AFTER_REPLY}' callbacks. To
            ensure that your tasks are executed, consider enabling:

              config.invoke_even_if_server_is_unsupported = true

            Note that this option, when combined with `inline: true` can result
            in delayed flushing of HTTP responses by the server (defeating the
            purpose of the gem.
          MSG
        else
          RunsCallbacks.new.call
        end

        if Store.instance.callbacks.any? { |cb| cb.inline }
          headers["Connection"] = "close"
        end
      end
      [status, headers, body]
    end
  end
end
