# frozen_string_literal: true

require "test_helper"

class TestReactorLmapOnEvent < Minitest::Test
  describe ".lmap_on_action_result" do
    it "maps on react" do
      reactor = Decider::Reactor.define do
        react :result do
          issue :action
        end
      end

      reactor = Decider::Reactor.lmap_on_action_result(
        ->(ar) { ar.to_sym },
        reactor
      )

      actions = reactor.react("result")

      assert_includes(actions, :action)
    end
  end

  describe "#lmap_on_action_result" do
    it "maps on react" do
      reactor = Decider::Reactor.define do
        react :result do
          issue :action
        end
      end

      reactor = reactor.lmap_on_action_result(
        ->(ar) { ar.to_sym }
      )

      actions = reactor.react("result")

      assert_includes(actions, :action)
    end
  end
end
