# http://datachomp.com/archives/using-unicorn-with-sinatra-or-padrino-on-heroku/
# https://devcenter.heroku.com/articles/rails-unicorn

worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
timeout 15
preload_app true
