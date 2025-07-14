# frozen_string_literal: true

require "test_helper"

class ReactorTestReact < Minitest::Test
  ActionResult = Data.define(:value)
  Action = Data.define(:value)

  describe "#react" do
    it "produces nothing when nothing matches" do
      reactor = Decider::Reactor.define do
        react :result do
          issue :action
        end
      end

      assert_empty reactor.react(:nothing)
    end

    it "allows to define catch-all" do
      reactor = Decider::Reactor.define do
        react :result do
          issue :action
        end

        react proc { true } do
          issue :nothing
        end
      end

      actions = reactor.react(:nothing)

      assert_equal 1, actions.size
      assert_includes actions, :nothing
    end

    it "matches action result" do
      reactor = Decider::Reactor.define do
        react :result do
          issue :action
        end
      end

      actions = reactor.react(:result)

      assert_includes actions, :action
    end

    it "can pattern match" do
      reactor = Decider::Reactor.define do
        react proc { action_result in ActionResult(value: 1) } do
          issue Action.new(value: action_result.value)
        end
      end

      actions = reactor.react(ActionResult.new(value: 1))

      assert_equal 1, actions.size
      assert_includes actions, Action.new(value: 1)
    end

    it "issues multiple actions" do
      reactor = Decider::Reactor.define do
        react :result do
          issue :foo
          issue :bar
        end
      end

      actions = reactor.react(:result)

      assert_equal 2, actions.size
      assert_includes actions, :foo
      assert_includes actions, :bar
    end
  end
end
