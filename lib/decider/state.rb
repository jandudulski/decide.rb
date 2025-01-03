# frozen_string_literal: true

module Decider
  class State
    def initialize(decider:, repository:)
      @decider = decider
      @repository = repository
    end

    def call(command, key:, etag: nil)
      state, etag = repository.try_load(key: key, etag: etag)

      events = decider.decide(command, state)
      new_state = events.reduce(state, &decider.method(:evolve))

      new_etag = repository.save(new_state, key: key, etag: etag)

      [events, new_etag]
    end

    private

    attr_reader :decider, :repository
  end
end
