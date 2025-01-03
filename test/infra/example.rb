# frozen_string_literal: true

module Infra
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
end
