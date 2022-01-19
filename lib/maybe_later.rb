require_relative "maybe_later/version"
require_relative "maybe_later/config"
require_relative "maybe_later/middleware"
require_relative "maybe_later/queues_callback"
require_relative "maybe_later/runs_callbacks"
require_relative "maybe_later/store"
require_relative "maybe_later/railtie" if defined?(Rails)

module MaybeLater
  def self.run(&blk)
    QueuesCallback.new.call(blk)
  end

  def self.config(&blk)
    (@config ||= Config.new).tap { |config|
      blk&.call(config)
    }
  end
end
