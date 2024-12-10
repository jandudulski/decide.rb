# frozen_string_literal: true

module Decider
  StateAlreadyDefined = Class.new(StandardError)
  StateNotDefined = Class.new(StandardError)

  Pair = Data.define(:left, :right)

  class Left
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def deconstruct
      [:left, value]
    end

    def ==(other)
      value == other.value
    end
  end

  class Right
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def deconstruct
      [:right, value]
    end

    def ==(other)
      value == other.value
    end
  end

  class Module < ::Module
    DECIDE_FALLBACK = proc { [nil, proc { [] }] }
    EVOLVE_FALLBACK = proc { [nil, proc { state }] }

    Decide = Data.define(:command, :state)
    Evolve = Data.define(:state, :event)
    Terminal = Data.define(:state)

    def initialize(initial_state:, deciders:, evolutions:, terminal:)
      define_method(:initial_state) do
        initial_state
      end

      define_method(:decide) do |command, state|
        context = Decide.new(command: command, state: state)

        deciders.find(DECIDE_FALLBACK) do |args, _|
          case args
          in [Proc => fn]
            context.instance_exec(&fn)
          in [ctype]
            command in ^ctype
          in [ctype, stype]
            [command, state] in [^ctype, ^stype]
          else
            false
          end
        end => [_, handler]

        context.instance_exec(&handler)
      end

      define_method(:evolve) do |state, event|
        context = Evolve.new(state: state, event: event)

        evolutions.find(EVOLVE_FALLBACK) do |args, _|
          case args
          in [Proc => fn]
            context.instance_exec(&fn)
          in [etype]
            event in ^etype
          in [stype, etype]
            [state, event] in [^stype, ^etype]
          else
            false
          end
        end => [_, handler]

        context.instance_exec(&handler)
      end

      define_method(:terminal?) do |state|
        context = Terminal.new(state: state)

        context.instance_exec(&terminal)
      end
    end
  end

  class Builder
    DEFAULT = Object.new

    attr_reader :module

    def initialize
      @initial_state = DEFAULT
      @deciders = {}
      @evolutions = {}
      @terminal = proc { false }
    end

    def build(&block)
      instance_exec(&block) if block_given?

      raise StateNotDefined if @initial_state == DEFAULT

      decider = Class.new

      @module = Module.new(
        initial_state: @initial_state,
        deciders: deciders,
        evolutions: evolutions,
        terminal: terminal
      )

      decider.extend(@module)

      decider
    end

    private

    attr_reader :deciders, :evolutions, :terminal

    def initial_state(state)
      raise StateAlreadyDefined if @initial_state != DEFAULT

      @initial_state = state
    end

    def decide(*args, &block)
      deciders[args] = block
    end

    def evolve(*args, &block)
      evolutions[args] = block
    end

    def terminal?(&block)
      @terminal = block
    end
  end
  private_constant :Builder

  def self.define(&block)
    builder = Builder.new
    builder.build(&block)
  end

  def self.compose(left, right)
    define do
      initial_state Pair.new(
        left: left.initial_state,
        right: right.initial_state
      )

      decide proc { [command] in [[:left, _]] } do
        left.decide(command.value, state.left).map { Left.new(_1) }
      end

      decide proc { [command] in [[:right, _]] } do
        right.decide(command.value, state.right).map { Right.new(_1) }
      end

      evolve proc { [event] in [[:left, _]] } do
        state.with(
          left: left.evolve(state.left, event.value)
        )
      end

      evolve proc { [event] in [[:right, _]] } do
        state.with(
          right: right.evolve(state.right, event.value)
        )
      end

      terminal? do
        left.terminal?(state.left) && right.terminal?(state.right)
      end
    end
  end
end
