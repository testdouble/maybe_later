module MaybeLater
  class Store
    def self.instance
      Thread.current[:maybe_later_store] ||= new
    end

    attr_reader :callbacks
    def initialize
      @callbacks = []
    end

    def any_callbacks?
      !@callbacks.empty?
    end

    def add_callback(callable)
      @callbacks << callable
    end

    def clear_callbacks!
      @callbacks = []
    end
  end
end
