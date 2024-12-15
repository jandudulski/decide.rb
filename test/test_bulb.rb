# frozen_string_literal: true

require "test_helper"

class TestBulb < Minitest::Test
  Fit = Data.define(:max_uses)
  SwitchOn = Data.define
  SwitchOff = Data.define

  Fitted = Data.define(:max_uses)
  SwitchedOn = Data.define
  SwitchedOff = Data.define
  Blew = Data.define

  NotFitted = Data.define
  Working = Data.define(:status, :remaining_uses)
  Blown = Data.define

  BulbDecider = Decider.define do
    initial_state NotFitted.new

    terminal? { state in Blown }

    decide Fit, NotFitted do
      emit Fitted.new(max_uses: command.max_uses)
    end

    decide Fit do
      raise "Bulb has already been fitted"
    end

    decide proc { [command, state] in [SwitchOn, Working(status: :off, remaining_uses: 0)] } do
      emit Blew.new
    end

    decide proc { [command, state] in [SwitchOn, Working(status: :off)] } do
      emit SwitchedOn.new
    end

    decide proc { [command, state] in [SwitchOff, Working(status: :on)] } do
      emit SwitchedOff.new
    end

    evolve Fitted do
      Working.new(status: :off, remaining_uses: event.max_uses)
    end

    evolve SwitchedOn do
      state.with(status: :on, remaining_uses: state.remaining_uses - 1)
    end

    evolve SwitchedOff do
      state.with(status: :off)
    end

    evolve Blew do
      Blown.new
    end
  end

  describe "bulb decider" do
    it "fits" do
      With.new(
        self, BulbDecider
      ).given(
        []
      ).when(
        Fit.new(max_uses: 5)
      ).then(
        [Fitted.new(max_uses: 5)]
      )
    end

    it "errors when trying to fit fitted bulb" do
      decider = With.new(
        self, BulbDecider
      ).given(
        [Fitted.new(max_uses: 5)]
      )

      assert_raises(RuntimeError, "Bulb has already been fitted") {
        decider.when(Fit.new(max_uses: 1))
      }
    end

    it "switch on" do
      With.new(
        self, BulbDecider
      ).given(
        [Fitted.new(max_uses: 5)]
      ).when(
        SwitchOn.new
      ).then(
        [SwitchedOn.new]
      )
    end

    it "does nothing when already switched on" do
      With.new(
        self, BulbDecider
      ).given(
        [
          Fitted.new(max_uses: 5),
          SwitchedOn.new
        ]
      ).when(
        SwitchOn.new
      ).then(
        []
      )
    end

    it "does not switch on when already blown" do
      With.new(
        self, BulbDecider
      ).given(
        [
          Blew.new
        ]
      ).when(
        SwitchOn.new
      ).then(
        []
      )
    end

    it "switch off" do
      With.new(
        self, BulbDecider
      ).given(
        [
          Fitted.new(max_uses: 5),
          SwitchedOn.new
        ]
      ).when(
        SwitchOff.new
      ).then(
        [SwitchedOff.new]
      )
    end

    it "does nothing when already switched off" do
      With.new(
        self, BulbDecider
      ).given(
        [
          Fitted.new(max_uses: 5),
          SwitchedOn.new,
          SwitchedOff.new
        ]
      ).when(
        SwitchOff.new
      ).then(
        []
      )
    end

    it "does not switch off when already blown" do
      With.new(
        self, BulbDecider
      ).given(
        [
          Blew.new
        ]
      ).when(
        SwitchOff.new
      ).then(
        []
      )
    end

    it "blew" do
      With.new(
        self, BulbDecider
      ).given(
        [
          Fitted.new(max_uses: 2),
          SwitchedOn.new,
          SwitchedOff.new,
          SwitchedOn.new,
          SwitchedOff.new
        ]
      ).when(
        SwitchOn.new
      ).then(
        [Blew.new]
      )
    end
  end
end
