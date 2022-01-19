module MaybeLater
  class RunsCallbacks
    def call
      Store.instance.callbacks.each do |callback|
        callback.call
      rescue => e
        MaybeLater.config.on_error&.call(e)
      ensure
        MaybeLater.config.after_each&.call
      end

      Store.instance.clear_callbacks!
    end
  end
end
