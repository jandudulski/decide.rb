# frozen_string_literal: true

require "test_helper"

class TestReactorCombineWithDecider < Minitest::Test
  State = Data.define(:value)
  Command = Data.define(:value)
  Event = Data.define(:value, :state)

  describe ".combine_with_decider" do
    it "reacts to emited events and decides on issued commands" do
      decider = Decider.define do
        initial_state State.new(value: 0)

        decide proc { [command, state] in [Command, State(value: 0)] } do
          emit Event.new(value: command.value, state: state.value)
          emit Event.new(value: command.value + 1, state: state.value)
        end

        decide Command do
          emit Event.new(value: command.value * 2, state: state.value)
        end

        evolve Event do
          state.with(value: state.value + event.value)
        end
      end

      reactor = Decider::Reactor.define do
        react proc { action_result in Event(value: 1) } do
          issue Command.new(value: 2)
          issue Command.new(value: 3)
        end

        react proc { action_result in Event(value: 2) } do
          issue Command.new(value: 4)
        end
      end

      decider = Decider::Reactor.combine_with_decider(reactor, decider)

      events = decider.decide(Command.new(value: 1), decider.initial_state)

      assert_equal events, [
        Event.new(value: 1, state: 0),
        Event.new(value: 2, state: 0),
        Event.new(value: 4, state: 3),
        Event.new(value: 6, state: 7),
        Event.new(value: 8, state: 13)
      ]
    end
  end

  describe "#combine_with_decider" do
    it "reacts to emited events and decides on issued commands" do
      decider = Decider.define do
        initial_state State.new(value: 0)

        decide proc { [command, state] in [Command, State(value: 0)] } do
          emit Event.new(value: command.value, state: state.value)
          emit Event.new(value: command.value + 1, state: state.value)
        end

        decide Command do
          emit Event.new(value: command.value * 2, state: state.value)
        end

        evolve Event do
          state.with(value: state.value + event.value)
        end
      end

      reactor = Decider::Reactor.define do
        react proc { action_result in Event(value: 1) } do
          issue Command.new(value: 2)
          issue Command.new(value: 3)
        end

        react proc { action_result in Event(value: 2) } do
          issue Command.new(value: 4)
        end
      end

      decider = reactor.combine_with_decider(decider)

      events = decider.decide(Command.new(value: 1), decider.initial_state)

      assert_equal events, [
        Event.new(value: 1, state: 0),
        Event.new(value: 2, state: 0),
        Event.new(value: 4, state: 3),
        Event.new(value: 6, state: 7),
        Event.new(value: 8, state: 13)
      ]
    end
  end
end
