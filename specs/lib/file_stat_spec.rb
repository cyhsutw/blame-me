# frozen_string_literal: true
require_relative '../spec_helper.rb'

describe 'FileStat' do
  let(:file_stat) do
    FileStat.new(
      name: '.gitignore',
      type: :blob,
      path: '.gitignore',
      parent_path: nil,
      stats: [
        'coder@me.coding' => 10,
        'another.coder@me.coding' => 20
      ]
    )
  end

  describe '::new' do
    it 'creates an instance of FileStat' do
      file_stat.must_be_instance_of FileStat
    end

    it 'sets instance variables' do
      %w(name type path parent_path stats).each do |variable_name|
        file_stat.instance_variable_get(:"@#{variable_name}").wont_be_nil
      end
    end
  end
end
