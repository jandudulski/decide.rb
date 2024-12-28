# frozen_string_literal: true

require "concurrent-ruby"

module Decider
  class InMemory
    def initialize(decider)
      @decider = decider
      @atom = Concurrent::Atom.new(decider.initial_state)
    end

    def call(command)
      events = decider.decide(command, state)
      atom.swap { |state| events.reduce(state, &decider.method(:evolve)) }
      events
    end

    def state
      atom.value
    end

    private

    attr_reader :decider, :atom
  end
end
