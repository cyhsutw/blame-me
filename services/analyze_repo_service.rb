# frozen_string_literal: true

class AnalyzeRepoService
  extend Dry::Monads::Either::Mixin
  extend Dry::Container::Mixin

  REPO_URL_REGEX = %r{(http|https):\/\/.+}

  def self.call(params)
    info = {
      params: params
    }

    Dry.Transaction(container: self) do
      step :validate_params
      step :create_repo_processor
      step :process_repo
    end.call(info)
  end

  register :validate_params, lambda { |info|
    repo_url = info.dig(:params, 'repo_url')
    if repo_url&.match?(REPO_URL_REGEX)
      info[:repo_url] = repo_url
      Right(info)
    else
      Left(Error.new('Invalid URL for repository, please check your repository URL.'))
    end
  }

  register :create_repo_processor, lambda { |info|
    repo_url = info.dig(:repo_url)
    begin
      processor = RepoProcessor.new(repo_url)
      info[:processor] = processor
      Right(info)
    rescue
      Left(Error.new('Error cloning your repository, please check your repository URL.'))
    end
  }

  register :process_repo, lambda { |info|
    processor = info.dig(:processor)
    begin
      stats = processor.repo_stats
      Right(stats)
    rescue
      Left(Error.new('Error processing your repository, please try again later.'))
    ensure
      processor.destroy_repo!
    end
  }
end
