# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'rack'
require 'sidekiq'
require_relative 'lib/tesla_puck'
require 'sidekiq/web'

config = TeslaPuck::Config.new

use Rack::Auth::Basic, 'TeslaPuck' do |_username, password|
  config.web_password == password
end

run Sidekiq::Web
