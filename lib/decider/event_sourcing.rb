# frozen_string_literal: true

module Decider
  class EventSourcing
    def initialize(decider:, event_store:)
      @decider = decider
      @event_store = event_store
    end

    def call(command, stream_name:)
      events = event_store.read.stream(stream_name)
      state = events.reduce(decider.initial_state, &decider.method(:evolve))

      new_events = decider.decide(command, state)

      event_store.append(new_events, stream_name: stream_name, expected_version: events.count)

      [new_events, events.count + new_events.count]
    end

    private

    attr_reader :decider, :event_store
  end
end
