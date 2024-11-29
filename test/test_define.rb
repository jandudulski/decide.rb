# frozen_string_literal: true

require "test_helper"

class TestDefine < Minitest::Spec
  describe ".define" do
    it "creates a new class" do
      decider = Decider.define do
        initial_state :foo
      end

      assert_pattern { Class === decider }
    end
  end
end
