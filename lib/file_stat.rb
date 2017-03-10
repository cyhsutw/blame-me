# frozen_string_literal: true
class FileStat
  attr_reader :name, :type, :path, :parent_path, :stats

  def initialize(**options)
    @name = options[:name]
    @type = options[:type]
    @path = options[:path]
    @parent_path = options[:parent_path] || '.'
    @stats = options[:stats]
  end
end
