# frozen_string_literal: true
require_relative '../spec_helper.rb'

describe 'AnalyzeRepoService' do
  describe '::call' do
    describe 'with valid params' do
      before(:all) do
        params = {
          'repo_url' => 'https://github.com/sinatra/sinatra.git'
        }
        @result = AnalyzeRepoService.call(params)
      end

      it 'returns a Dry::Monads::Either::Right' do
        @result.must_be_instance_of Dry::Monads::Either::Right
      end

      it 'succeeds' do
        @result.success?.must_equal true
      end

      it 'contains the resulting statistics' do
        @result.value.must_be_instance_of Array
        @result.value.all? { |stat| stat.is_a? FileStat }.must_equal true
      end
    end

    describe 'with invalid params' do
      describe 'missing repo_url param' do
        before(:all) do
          params = {}
          @result = AnalyzeRepoService.call(params)
        end

        it 'returns a Dry::Monads::Either::Left' do
          @result.must_be_instance_of Dry::Monads::Either::Left
        end

        it 'fails' do
          @result.success?.must_equal false
        end
      end

      describe 'malformed repo_url param' do
        before(:all) do
          params = { 'repo_url' => 'https://not-github.com/sinatra/sinatra.git' }
          @result = AnalyzeRepoService.call(params)
        end

        it 'returns a Dry::Monads::Either::Left' do
          @result.must_be_instance_of Dry::Monads::Either::Left
        end

        it 'fails' do
          @result.success?.must_equal false
        end
      end
    end
  end
end
