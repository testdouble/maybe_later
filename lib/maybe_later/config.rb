module MaybeLater
  class Config
    attr_accessor :after_each, :on_error

    def initialize
      @after_each = nil
      @on_error = nil
    end
  end
end
