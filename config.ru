# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'dotenv/load'
require 'rack'
require 'sidekiq'
require_relative 'lib/tesla_puck'
require 'sidekiq/web'
require 'sidekiq-scheduler/web'

run Sidekiq::Web
