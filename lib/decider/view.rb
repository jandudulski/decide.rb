# frozen_string_literal: true

module Decider::View
  class Module < ::Module
    EVOLVE_FALLBACK = proc { [nil, proc { state }] }

    Evolve = Data.define(:state, :event) do
      def self.build(state, event)
        new(state: state, event: event)
      end
    end

    def initialize(initial_state:, evolutions:)
      define_method(:initial_state) do
        initial_state
      end

      define_method(:evolve) do |*args|
        if args.empty?
          ->(state, event) { evolve(state, event) }
        else
          context = Evolve.build(*args)

          evolutions.find(EVOLVE_FALLBACK) do |args, _|
            case args
            in [Proc => fn]
              context.instance_exec(&fn)
            in [etype]
              context_event = context.event
              context_event in ^etype
            in [stype, etype]
              context_state = context.state
              context_event = context.event
              [context_state, context_event] in [^stype, ^etype]
            else
              false
            end
          end => [_, handler]

          context.instance_exec(&handler)
        end
      end

      define_method(:lmap_on_event) do |fn|
        Decider::View.lmap_on_event(fn, self)
      end

      define_method(:lmap_on_state) do |fn|
        Decider::View.lmap_on_state(fn, self)
      end

      define_method(:rmap_on_state) do |fn|
        Decider::View.rmap_on_state(fn, self)
      end

      define_method(:dimap_on_state) do |fl:, fr:|
        Decider::View.dimap_on_state(fl, fr, self)
      end
    end
  end

  class Builder
    DEFAULT = Object.new

    def initialize
      @initial_state = DEFAULT
      @evolutions = {}
    end

    def build(&block)
      instance_exec(&block) if block_given?

      raise StateNotDefined if @initial_state == DEFAULT

      view = Class.new

      mod = Module.new(
        initial_state: @initial_state,
        evolutions: evolutions
      )

      view.extend(mod)

      view
    end

    private

    attr_reader :evolutions

    def initial_state(state)
      raise StateAlreadyDefined if @initial_state != DEFAULT

      @initial_state = state
    end

    def evolve(*args, &block)
      evolutions[args] = block
    end
  end
  private_constant :Builder

  def self.define(&block)
    builder = Builder.new
    builder.build(&block)
  end

  def self.lmap_on_event(fn, view)
    define do
      initial_state view.initial_state

      evolve proc { true } do
        view.evolve(state, fn.call(event))
      end
    end
  end

  def self.lmap_on_state(fn, view)
    dimap_on_state(fn, ->(state) { state }, view)
  end

  def self.rmap_on_state(fn, view)
    dimap_on_state(->(state) { state }, fn, view)
  end

  def self.dimap_on_state(fl, fr, view)
    define do
      initial_state fr.call(view.initial_state)

      evolve proc { true } do
        fr.call(view.evolve(fl.call(state), event))
      end
    end
  end
end
