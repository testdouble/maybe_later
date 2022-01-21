module MaybeLater
  class RunsCallbacks
    def initialize
      @invokes_callback = InvokesCallback.new
    end

    def call
      store = Store.instance

      store.callbacks.each do |callback|
        if callback.inline
          @invokes_callback.call(callback)
        else
          ThreadPool.instance.run(callback)
        end
      end

      store.clear_callbacks!
    end
  end
end
