module AfterAction
  class RunsCallbacks
    def call
      Store.instance.callbacks.each do |callback|
        callback.call
      rescue
        e = Error.new("Error running callback #{callback.inspect}. See #cause for the error or #callback for the reference to the callable")
        e.callback = callback
        AfterAction.config.on_error&.call(e)
      ensure
        AfterAction.config.after_each&.call
      end

      Store.instance.clear_callbacks!
    end
  end
end
