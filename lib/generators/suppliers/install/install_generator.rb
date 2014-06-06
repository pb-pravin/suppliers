module Suppliers
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    desc "Initializes the suppliers plugin."

    class_option :namespace,  type: :string,  default: "suppliers", description: "The plugin routes namespace in the app."
    class_option :migrations, type: :boolean, default: true, description: "Run migrations"

    def add_initializer
      template "init.erb", "config/initializers/suppliers.rb"
    end

    def copy_migrations
      rake "suppliers:install:migrations"
    end

    def run_migrations
      if options[:migrations]
        rake "db:migrate SCOPE=suppliers"
      end
    end

    def mount_routes
      inject_into_file "config/routes.rb", before: "\nend" do
        "\n  mount Suppliers::Engine => \"/#{ namespace }\""
      end
    end

    private

      def user_model
        options[:user_model].camelize
      end

      def namespace
        @namespace ||= options[:namespace].underscore
      end
  end
end