module MaybeLater
  class Config
    attr_accessor :after_each, :on_error, :inline_by_default, :max_threads,
      :invoke_even_if_server_is_unsupported

    def initialize
      @after_each = nil
      @on_error = nil
      @inline_by_default = false
      @max_threads = 5
      @invoke_even_if_server_is_unsupported = false
    end
  end
end
