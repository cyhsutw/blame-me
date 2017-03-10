# frozen_string_literal: true
require_relative '../spec_helper.rb'

describe 'RepoProcessor' do
  REPO_URL = 'https://github.com/sinatra/sinatra.git'.freeze

  before(:all) do
    # this is expensive, do it per `describe`
    @processor = RepoProcessor.new(REPO_URL)
  end

  after(:all) do
    @processor.destroy_repo!
  end

  describe '::new' do
    it 'creates an instance of RepoProcessor' do
      @processor.must_be_instance_of RepoProcessor
    end

    it 'sets `repo_url` instance variable' do
      @processor.instance_variable_get(:@repo_url).wont_be_nil
    end

    it 'sets `path` instance variable' do
      @processor.instance_variable_get(:@path).wont_be_nil
    end

    it 'clones to repository to a specific folder' do
      git_dir = File.join(@processor.instance_variable_get(:@path), '.git')
      File.directory?(git_dir).must_equal true
    end
  end

  describe 'accessors' do
    describe '#path' do
      it 'returns the value of the `@path` instance variable' do
        @processor.path.must_equal @processor.instance_variable_get(:@path)
      end
    end

    describe '#repo_url' do
      it 'returns the value of the `@repo_url` instance variable' do
        @processor.repo_url.must_equal @processor.instance_variable_get(:@repo_url)
      end
    end
  end

  describe '#destroy_repo!' do
    before(:all) do
      @repo_path = @processor.path
      @processor.destroy_repo!
    end

    it 'deletes the git repository' do
      Dir.exist?(@repo_path).must_equal false
    end

    it 'clears the value of `@path`' do
      @processor.path.must_be_nil
    end
  end
end
