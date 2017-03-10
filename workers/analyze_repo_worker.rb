# frozen_string_literal: true
class AnalyzeRepoWorker
  include Sidekiq::Worker
  def perform(params, pubsub = nil)
    AnalyzeRepoService.call(params, pubsub: pubsub)
  end
end
