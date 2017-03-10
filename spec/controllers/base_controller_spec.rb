# frozen_string_literal: true
require_relative '../spec_helper.rb'

describe 'base controller' do
  describe 'root route' do
    before { get '/' }

    it 'succeeds' do
      last_response.must_be_ok
    end
  end
end
