module MaybeLater
  class InvokesCallback
    def call(callback)
      config = MaybeLater.config

      callback.callable.call
    rescue => e
      config.on_error&.call(e)
    ensure
      config.after_each&.call
    end
  end
end
