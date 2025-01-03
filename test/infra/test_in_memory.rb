# frozen_string_literal: true

require "test_helper"
require "infra/example"
require "decider/in_memory"

module Infra
  class TestInMemory < Minitest::Spec
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

        threads = Array.new(4) do
          Thread.new { handler.call(:slow) }
        end
        threads.each(&:join)

        assert_equal 4, handler.state
      end
    end
  end
end
