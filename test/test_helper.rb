# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "debug"
require "decider"

require "minitest/autorun"

module DeciderHelpers
  class Context
    def initialize(context, decider)
      @context = context
      @decider = decider
      @state = decider.initial_state
    end

    def given(*events)
      @state = events.reduce(state, &decider.method(:evolve))

      self
    end

    def when(command)
      @command = command

      self
    end

    def then(*events)
      context.assert_equal(events, result)
    end

    def then_nothing
      context.assert_empty(result)
    end

    def then_error(*args)
      context.assert_raises(*args) { result }
    end

    private

    attr_reader :context, :decider, :command, :state

    def result
      decider.decide(command, state)
    end
  end

  def With(decider)
    Context.new(self, decider)
  end
end
