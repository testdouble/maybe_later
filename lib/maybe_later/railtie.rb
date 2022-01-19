module MaybeLater
  class Railtie < ::Rails::Railtie
    initializer "maybe_later.middleware" do
      config.app_middleware.use Middleware
    end
  end
end
