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
    def initialize(initial_state:, deciders:, evolvers:, terminal:)
      define_method(:initial_state) do
        initial_state
      end

      define_method(:commands) do
        deciders.keys
      end

      define_method(:events) do
        evolvers.keys
      end

      define_method(:decide!) do |command, state|
        handler = deciders.fetch(command.class) {
          raise ArgumentError, "Unknown command: #{command.class}"
        }

        handler.call(command, state)
      end

      define_method(:decide) do |command, state|
        handler = deciders.fetch(command.class) {
          return []
        }

        handler.call(command, state)
      end

      define_method(:evolve!) do |state, event|
        handler = evolvers.fetch(event.class) {
          raise ArgumentError, "Unknown event: #{event.class}"
        }

        handler.call(state, event)
      end

      define_method(:evolve) do |state, event|
        handler = evolvers.fetch(event.class) {
          return state
        }

        handler.call(state, event)
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
      @evolvers = {}
      @terminal = ->(_state) { false }
    end

    def build(&block)
      instance_exec(&block) if block_given?

      raise StateNotDefined if @initial_state == DEFAULT

      decider = Object.new

      @module = Module.new(
        initial_state: @initial_state,
        deciders: deciders,
        evolvers: evolvers,
        terminal: terminal
      )

      decider.extend(@module)

      decider
    end

    private

    attr_reader :deciders, :evolvers, :terminal

    def initial_state(state)
      raise StateAlreadyDefined if @initial_state != DEFAULT

      @initial_state = state
    end

    def decide(command, &block)
      deciders[command] = block
    end

    def evolve(event, &block)
      evolvers[event] = block
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
