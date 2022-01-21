module MaybeLater
  class ThreadPool
    def self.instance
      @instance ||= new
    end

    # The only time this is invoked by the gem will be when an Async task runs
    # As a result, the max thread config will be locked after responding to the
    # first relevant request, since the pool will have been created
    def initialize
      @pool = Concurrent::FixedThreadPool.new(MaybeLater.config.max_threads)
      @invokes_callback = InvokesCallback.new
    end

    def run(callback)
      @pool.post do
        @invokes_callback.call(callback)
      end
    end
  end
end
