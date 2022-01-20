module MaybeLater
  class Config
    attr_accessor :after_each, :on_error, :inline_by_default, :max_threads

    def initialize
      @after_each = nil
      @on_error = nil
      @inline_by_default = false
      @max_threads = 5
    end
  end
end
