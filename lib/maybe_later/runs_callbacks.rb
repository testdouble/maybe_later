module MaybeLater
  class RunsCallbacks
    def call
      store = Store.instance
      config = MaybeLater.config

      store.callbacks.each do |callback|
        if callback.inline
          callback.callable.call
        else
          ThreadPool.instance.run(callback.callable)
        end
      rescue => e
        config.on_error&.call(e)
      ensure
        config.after_each&.call
      end

      store.clear_callbacks!
    end
  end
end
