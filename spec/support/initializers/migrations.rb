# Отложенные миграции
require "active_record"

ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)