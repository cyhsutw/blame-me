# frozen_string_literal: true
folders = 'lib,values,services,controllers,workers'

Dir.glob("./{#{folders}}/init.rb").each do |file|
  require file
end
