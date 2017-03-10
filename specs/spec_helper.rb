# frozen_string_literal: true
require 'minitest/autorun'
require 'minitest/rg'
require 'minitest/hooks/default'
require 'rack-minitest/test'

%w(lib controllers).each do |folder|
  require_relative "../#{folder}/init.rb"
end

def app
  BlameMe
end
