if defined?(::Rails::Railtie)
  module RackMojAuth
    class Railtie < Rails::Railtie
      initializer "RackMojAuth.configure_rails_initialization" do |app|
        app.middleware.use RackMojAuth::Middleware
      end
    end
  end
 end