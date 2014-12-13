require 'rubygems'
require 'bundler'
Bundler.require

set :env, :development
disable :run

require './app.rb'
run Sinatra::Application
