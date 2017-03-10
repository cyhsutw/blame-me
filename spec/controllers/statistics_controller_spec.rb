# frozen_string_literal: true
require_relative '../spec_helper.rb'

describe 'statistics controller' do
  describe 'base route' do
    describe 'GET' do
      before { get '/statistics' }

      it 'succeeds' do
        get '/statistics'
        last_response.must_be_ok
      end
    end

    describe 'POST' do
      before { post '/statistics' }

      it 'redirects to `/statistics`' do
        last_response.status.must_equal 302
      end
    end
  end
end
