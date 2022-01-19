module AfterAction
  class Store
    def self.instance
      Thread.current[:after_action_store] ||= new
    end

    attr_reader :callbacks
    def initialize
      @callbacks = []
    end

    def add_callback(callable)
      @callbacks << callable
    end

    def clear_callbacks!
      @callbacks = []
    end
  end
end
