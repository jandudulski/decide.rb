# frozen_string_literal: true

require "test_helper"

class TestTerminal < Minitest::Test
  describe "#terminal?" do
    it "returns false by default" do
      decider = Decider.define do
        initial_state :working
      end

      refute decider.terminal?(:broken)
    end

    it "returns false when not terminated" do
      decider = Decider.define do
        initial_state :working

        terminal? do |state|
          state == :broken
        end
      end

      refute decider.terminal?(:working)
    end

    it "returns true when terminated" do
      decider = Decider.define do
        initial_state :working

        terminal? do |state|
          state == :broken
        end
      end

      assert decider.terminal?(:broken)
    end
  end
end
