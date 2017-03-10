# frozen_string_literal: true
require 'rugged'
require 'tmpdir'
require 'fileutils'
require 'securerandom'

class RepoProcessor
  attr_reader :path, :repo_url

  def initialize(repo_url)
    @path = File.join(Dir.tmpdir, SecureRandom.urlsafe_base64(32))
    @repo_url = repo_url

    @repo = Rugged::Repository.clone_at(repo_url, path)
  end

  def destroy_repo!
    return if @path.nil?

    FileUtils.rm_rf(path)
    @path = nil
  end
end
