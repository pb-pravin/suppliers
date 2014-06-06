module Suppliers
  class UninstallGenerator < Rails::Generators::Base

    def dismount_routes
      gsub_file "config/routes.rb", /\n\s*mount Suppliers::Engine[^\n]*/, ""
    end

    def remove_initializer
      remove_file "config/initializers/Suppliers.rb"
    end

    def rollback_migrations
      rake "db:migrate SCOPE=Suppliers VERSION=0"
    end

    def remove_migrations
      run "rm db/migrate/*.Suppliers.rb"
    end

    def remove_from_gemfile
      gsub_file "Gemfile", gem_str, ""
    end

    def remove_from_gemspec
      begin
        gsub_file "#{ app_name }.gemspec", gem_str, ""
      rescue
      end
    end

    private

      def app_name
        Rails.application.class.parent_name.underscore
      end

      def gem_str
        /\n[^\n]*(\"|\')demands(\"|\')[^\n]*/
      end
  end
end