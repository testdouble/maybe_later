module AfterAction
  class QueuesCallback
    def call(blk)
      if blk.respond_to?(:call)
        Store.instance.add_callback(blk)
      end
    end
  end
end
