# frozen_string_literal: true
require 'minitest/autorun'
require 'minitest/rg'
require 'minitest/hooks/default'

['lib'].each do |folder|
  require_relative "../#{folder}/init.rb"
end
