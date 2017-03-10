# frozen_string_literal: true
require 'sinatra'
require 'sinatra/assetpack'
require 'slim/include'
require 'dotenv'
require 'securerandom'

Dotenv.load

Dir.glob("#{File.dirname(__FILE__)}/*.rb").each do |file|
  next if file.match?('init.rb')
  require file
end
