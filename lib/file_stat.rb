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

  def to_h
    Hash[
      %w(name type path parent_path stats).map do |attribute|
        [attribute.to_sym, instance_variable_get(:"@#{attribute}")]
      end
    ]
  end
end
