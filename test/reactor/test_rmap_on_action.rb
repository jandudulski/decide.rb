# frozen_string_literal: true

require "test_helper"

class TestReactorRmapOnAction < Minitest::Test
  describe ".rmap_on_action" do
    it "maps on react" do
      reactor = Decider::Reactor.define do
        react :result do
          issue :action
        end
      end

      reactor = Decider::Reactor.rmap_on_action(
        ->(action) { action.to_s },
        reactor
      )

      actions = reactor.react(:result)

      assert_includes(actions, "action")
    end
  end

  describe "#rmap_on_action" do
    it "maps on react" do
      reactor = Decider::Reactor.define do
        react :result do
          issue :action
        end
      end

      reactor = reactor.rmap_on_action(
        ->(action) { action.to_s }
      )

      actions = reactor.react(:result)

      assert_includes(actions, "action")
    end
  end
end
