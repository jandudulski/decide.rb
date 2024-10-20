# frozen_string_literal: true

module Decider
  StateAlreadyDefined = Class.new(StandardError)
  StateNotDefined = Class.new(StandardError)

  class Module < ::Module
    def initialize(initial_state_args:, deciders:, evolvers:)
      define_method(:initial_state) do
        new(**initial_state_args)
      end

      define_method(:decide) do |command, state|
        handler = deciders.fetch(command.class) {
          raise ArgumentError, "Unknown command: #{command.class}"
        }

        handler.call(command, state)
      end

      define_method(:evolve) do |state, event|
        handler = evolvers.fetch(event.class) {
          raise ArgumentError, "Unknown event: #{event.class}"
        }

        handler.call(state, event)
      end
    end
  end

  class Builder
    DEFAULT = Object.new

    attr_reader :module

    def initialize
      @state = DEFAULT
      @deciders = {}
      @evolvers = {}
    end

    def build(&block)
      instance_exec(&block) if block_given?

      raise StateNotDefined if @state == DEFAULT

      @module = Module.new(
        initial_state_args: initial_state_args,
        deciders: deciders,
        evolvers: evolvers
      )

      @state.extend(@module)

      @state
    end

    private

    attr_reader :initial_state_args, :deciders, :evolvers

    def state(**kwargs, &block)
      raise StateAlreadyDefined if @state != DEFAULT

      @state = Data.define(*kwargs.keys, &block)
      @initial_state_args = kwargs
    end

    def decide(command, &block)
      deciders[command] = block
    end

    def evolve(event, &block)
      evolvers[event] = block
    end
  end
  private_constant :Builder

  def self.define(&block)
    builder = Builder.new
    builder.build(&block)
  end
end
