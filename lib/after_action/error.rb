module AfterAction
  class Error < StandardError
    attr_accessor :callback
  end
end
