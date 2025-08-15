# frozen_string_literal: true

module Decider
  module Reactor
    class Module < ::Module
      REACT_FALLBACK = proc { [nil, proc {}] }

      React = Data.define(:action_result, :_actions) do
        def issue(*actions)
          _actions.push(*actions)
        end
      end

      def initialize(reactions:)
        define_method(:react) do |action_result|
          context = React.new(action_result: action_result, _actions: [])

          reactions.find(REACT_FALLBACK) do |arg, _|
            case arg
            in Proc => fn
              context.instance_exec(&fn)
            in artype
              action_result in ^artype
            else
              false
            end
          end => [_, handler]

          context.instance_exec(&handler)
          context._actions
        end

        define_method(:lmap_on_action_result) do |fn|
          Decider::Reactor.lmap_on_action_result(fn, self)
        end

        define_method(:rmap_on_action) do |fn|
          Decider::Reactor.rmap_on_action(fn, self)
        end

        define_method(:map_on_action) do |fn|
          Decider::Reactor.rmap_on_action(fn, self)
        end

        define_method(:combine_with_decider) do |decider|
          Decider::Reactor.combine_with_decider(self, decider)
        end
      end
    end

    class Builder
      DEFAULT = Object.new

      def initialize
        @reactions = {}
      end

      def build(&block)
        instance_exec(&block) if block_given?

        reactor = Class.new

        mod = Module.new(
          reactions: reactions
        )

        reactor.extend(mod)

        reactor
      end

      private

      attr_reader :reactions

      def react(arg, &block)
        reactions[arg] = block
      end
    end
    private_constant :Builder

    def self.define(&block)
      builder = Builder.new
      builder.build(&block)
    end

    def self.lmap_on_action_result(fn, reactor)
      define do
        react proc { true } do
          reactor.react(fn.call(action_result)).each do |action|
            issue action
          end
        end
      end
    end

    def self.rmap_on_action(fn, reactor)
      define do
        react proc { true } do
          reactor.react(action_result).each do |action|
            issue fn.call(action)
          end
        end
      end
    end

    def self.map_on_action(fn, reactor)
      rmap_on_action(fn, reactor)
    end

    def self.combine_with_decider(reactor, decider)
      Decider.define do
        initial_state decider.initial_state

        decide proc { true } do
          fn = ->(commands, events, ds) {
            case commands
            in []
              events
            in [head, *tail]
              new_events = decider.decide(head, ds)
              new_commands = new_events.flat_map { |action_result| reactor.react(action_result) }
              new_state = new_events.reduce(ds, &decider.evolve)

              fn.call(tail + new_commands, events + new_events, new_state)
            end
          }

          fn.call([command], [], state).each { |event| emit event }
        end

        evolve proc { true } do
          decider.evolve(state, event)
        end

        terminal? do
          decider.terminal?(state)
        end
      end
    end
  end
end
