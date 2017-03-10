# frozen_string_literal: true
folders = 'lib,values,services,controllers'

Dir.glob("./{#{folders}}/init.rb").each do |file|
  require file
end
