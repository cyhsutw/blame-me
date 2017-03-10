# frozen_string_literal: true
require 'sinatra'
require 'slim/include'
require 'dotenv'

Dotenv.load

Dir.glob("#{File.dirname(__FILE__)}/*.rb").each do |file|
  require file
end
