# frozen_string_literal: true
require 'minitest/autorun'
require 'minitest/rg'
require 'minitest/hooks/default'
require 'rack-minitest/test'
require_relative '../init.rb'

def app
  BlameMe
end
