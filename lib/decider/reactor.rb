# frozen_string_literal: true

module Decider::Reactor
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
    end
  end

  class Builder
    DEFAULT = Object.new

    attr_reader :module

    def initialize
      @reactions = {}
    end

    def build(&block)
      instance_exec(&block) if block_given?

      reactor = Class.new

      @module = Module.new(
        reactions: reactions
      )

      reactor.extend(@module)

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
end
