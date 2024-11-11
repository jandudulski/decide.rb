# frozen_string_literal: true

module Decider
  StateAlreadyDefined = Class.new(StandardError)
  StateNotDefined = Class.new(StandardError)

  class Composition < Array
    BLANK = Object.new
    private_constant :BLANK

    def initialize(left, right)
      super([left, right]).freeze
    end

    def with(left: BLANK, right: BLANK)
      Composition.new(
        (left == BLANK) ? self.left : left,
        (right == BLANK) ? self.right : right
      )
    end

    def left
      self[0]
    end

    def right
      self[1]
    end
  end

  class Module < ::Module
    def initialize(initial_state:, deciders:, evolutions:, terminal:)
      define_method(:initial_state) do
        initial_state
      end

      define_method(:commands) do
        deciders.keys
      end

      define_method(:events) do
        evolutions.keys
      end

      define_method(:decide!) do |command, state|
        case deciders.find { |key, _| key === command }
        in [_, handler]
          handler.call(command, state)
        else
          raise ArgumentError, "Unknown command: #{command.inspect}"
        end
      end

      define_method(:decide) do |command, state|
        case deciders.find { |key, _| key === command }
        in [_, handler]
          handler.call(command, state)
        else
          []
        end
      end

      define_method(:evolve!) do |state, event|
        case evolutions.find { |key, _| key === event }
        in [_, handler]
          handler.call(state, event)
        else
          raise ArgumentError, "Unknown event: #{event.inspect}"
        end
      end

      define_method(:evolve) do |state, event|
        case evolutions.find { |key, _| key === event }
        in [_, handler]
          handler.call(state, event)
        else
          state
        end
      end

      define_method(:terminal?) do |state|
        terminal.call(state)
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
      @terminal = ->(_state) { false }
    end

    def build(&block)
      instance_exec(&block) if block_given?

      raise StateNotDefined if @initial_state == DEFAULT

      decider = Object.new

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

    def decide(command, &block)
      deciders[command] = block
    end

    def evolve(event, &block)
      evolutions[event] = block
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
      initial_state Composition.new(left.initial_state, right.initial_state)

      left.commands.each do |klass|
        decide klass do |command, state|
          left.decide(command, state.left)
        end
      end

      right.commands.each do |klass|
        decide klass do |command, state|
          right.decide(command, state.right)
        end
      end

      left.events.each do |klass|
        evolve klass do |state, event|
          state.with(
            left: left.evolve(state.left, event)
          )
        end
      end

      right.events.each do |klass|
        evolve klass do |state, event|
          state.with(
            right: right.evolve(state.right, event)
          )
        end
      end

      terminal? do |state|
        left.terminal?(state.left) && right.terminal?(state.right)
      end
    end
  end
end
