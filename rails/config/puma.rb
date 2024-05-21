threads_count = ENV.fetch("RAILS_MAX_THREADS") { 1 }
threads threads_count, threads_count
workers ENV.fetch("WEB_CONCURRENCY") { 0 }
preload_app! if ENV['RACK_ENV'] == 'production'
port        ENV.fetch("PO RT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "development" }
plugin :tmp_restart
