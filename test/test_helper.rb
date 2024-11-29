# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "decider"

require "minitest/autorun"

class With
  def initialize(context, decider)
    @context = context
    @decider = decider
  end

  def given(events)
    @state = events.reduce(decider.initial_state, &decider.method(:evolve))

    self
  end

  def when(command)
    @result = decider.decide(command, state)

    self
  end

  def then(expected)
    context.assert_equal(expected, result)
  end

  private

  attr_reader :decider, :state, :result
end

def with(context, decider)
  With.new(context, decider)
end
