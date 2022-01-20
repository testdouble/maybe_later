module MaybeLater
  Callback = Struct.new(:inline, :callable, keyword_init: true)

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
