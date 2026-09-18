module MaybeLater
  # keyword_init is only redundant on Ruby 3.2+; without it, Ruby 3.1 silently
  # misassigns keyword args (the whole hash lands in the first member) instead
  # of raising, so we keep it and disable the cop rather than drop support.
  Callback = Struct.new(:inline, :callable, keyword_init: true) # standard:disable Style/RedundantStructKeywordInit

  class QueuesCallback
    def call(callable:, inline:)
      raise Error.new("No block was passed to MaybeLater.run") if callable.nil?

      inline = MaybeLater.config.inline_by_default if inline.nil?
      Store.instance.add_callback(Callback.new(
        inline: inline,
        callable: callable
      ))
    end
  end
end
