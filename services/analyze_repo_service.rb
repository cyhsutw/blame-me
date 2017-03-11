# frozen_string_literal: true

class AnalyzeRepoService
  extend Dry::Monads::Either::Mixin
  extend Dry::Container::Mixin

  REPO_URL_REGEX = %r{(http|https):\/\/.+}

  def self.call(params, pubsub: nil)
    wait_until_client_starts if pubsub

    info = {
      params: params,
      pubsub: pubsub
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
      error = Error.new('Invalid URL for repository, please check your repository URL.')
      publish({ error: error.message }, info.dig(:pubsub))
      Left(error)
    end
  }

  register :create_repo_processor, lambda { |info|
    repo_url = info.dig(:repo_url)
    begin
      processor = RepoProcessor.new(repo_url)
      info[:processor] = processor
      Right(info)
    rescue
      error = Error.new('Error cloning your repository, please check your repository URL.')
      publish({ error: error.message }, info.dig(:pubsub))
      Left(error)
    end
  }

  register :process_repo, lambda { |info|
    processor = info.dig(:processor)
    begin
      stats = processor.repo_stats
      publish({ data: stats.map(&:to_h) }, info.dig(:pubsub))
      Right(stats)
    rescue
      error = Error.new('Error processing your repository, please try again later.')
      publish({ error: error.message }, info.dig(:pubsub))
      Left(error)
    ensure
      processor.destroy_repo!
    end
  }

  private_class_method

  def self.wait_until_client_starts
    sleep 3.0
  end

  def self.publish(payload, pubsub_info)
    return unless pubsub_info&.dig('channel')
    return unless pubsub_info&.dig('server')
    HTTParty.post(
      pubsub_info.dig('server'),
      headers: { 'Content-Type' => 'application/json' },
      body: {
        channel: "/#{pubsub_info&.dig('channel')}",
        data: payload
      }.to_json
    )
  end
end
