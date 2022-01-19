require_relative "after_action/version"
require_relative "after_action/error"
require_relative "after_action/config"
require_relative "after_action/middleware"
require_relative "after_action/queues_callback"
require_relative "after_action/runs_callbacks"
require_relative "after_action/store"
require_relative "after_action/railtie" if defined?(Rails)

module AfterAction
  def self.run(&blk)
    QueuesCallback.new.call(blk)
  end

  def self.config(&blk)
    (@config ||= Config.new).tap { |config|
      blk&.call(config)
    }
  end
end
