# frozen_string_literal: true

require "test_helper"
require "decider/in_memory"

module Infra
  class TestInMemory < Minitest::Spec
    Example = Decider.define do
      initial_state 0

      decide :increase do
        emit :increased
      end

      decide :slow do
        emit :slow
      end

      decide :decrease do
        emit :decreased
      end

      evolve :increased do
        state + 1
      end

      evolve :decreased do
        state - 1
      end

      evolve :slow do
        sleep 0.1
        state + 1
      end
    end

    describe "#call" do
      it "returns decide result" do
        handler = Decider::InMemory.new(Example)

        assert_equal [:increased], handler.call(:increase)
        assert_equal [:decreased], handler.call(:decrease)
      end

      it "maintains state in memory" do
        handler = Decider::InMemory.new(Example)

        assert_equal 0, handler.state
        2.times { handler.call(:increase) }
        assert_equal 2, handler.state
        handler.call(:decrease)
        assert_equal 1, handler.state
      end

      it "handles race conditions" do
        handler = Decider::InMemory.new(Example)

        threads = Concurrent::Array.new(4) do
          Thread.new { handler.call(:slow) }
        end
        threads.each(&:run).each(&:join)

        assert_equal 4, handler.state
      end
    end
  end
end
