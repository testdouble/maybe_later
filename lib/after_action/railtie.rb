module AfterAction
  class Railtie < ::Rails::Railtie
    initializer "after_action.middleware" do
      config.app_middleware.use Middleware
    end
  end
end
