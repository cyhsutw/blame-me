# frozen_string_literal: true
Dir.glob("#{File.dirname(__FILE__)}/*.rb").each do |file|
  next if file.match?('init.rb')
  require file
end
