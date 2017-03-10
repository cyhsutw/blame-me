# frozen_string_literal: true
require_relative '../spec_helper.rb'

describe 'Error' do
  let(:error) { Error.new('Wrong way!') }

  describe '::new' do
    it 'creates an instance of Error' do
      error.must_be_instance_of Error
    end

    it 'sets instance variables' do
      %w(message).each do |variable_name|
        error.instance_variable_get(:"@#{variable_name}").wont_be_nil
      end
    end
  end
end
