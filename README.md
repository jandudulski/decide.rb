# Decider

This gem provides simple DSL for building Functional Event Sourcing Decider in Ruby. To learn more about the pattern read the original [article by Jérémie Chassaing](https://thinkbeforecoding.com/post/2021/12/17/functional-event-sourcing-decider).

Special credits for [Ismael Celis for inspiration](https://ismaelcelis.com/posts/decide-evolve-react-pattern-in-ruby/).

## Installation

```bash
gem install decide.rb
```

or add to Gemfile

```ruby
gem "decide.rb"
```

## Usage

```ruby
require "decider"

State = Data.define(:value) do
  def max?
    value >= MAX
  end
  
  def min?
    value <= MIN
  end
end

module Commands
  Increase = Data.define
  Decrease = Data.define
end

module Events
  ValueIncreased = Data.define
  ValueDecreased = Data.define
end

MIN = 0
MAX = 100

ValueDecider = Decider.define do
  # define intial state
  initial_state State.new(value: 0)

  # decide command with state
  decide Commands::Increase do |command, state|
    # return collection of events
    if state.max?
      []
    else
      [Events::ValueIncreased.new]
    end
  end

  decide Commands::Decrease do |command, state|
    if state.min?
      []
    else
      [Events::ValueDecreased.new]
    end
  end

  # evolve state with events
  evolve Events::ValueIncreased do |state, event|
    # return new state
    state.with(value: state.value + 1)
  end

  evolve Events::ValueDecreased do |state, event|
    # state is immutable Data object
    state.with(value: state.value - 1)
  end

  terminal? do |state|
    state <= 0
  end
end

state = ValueDecider.initial_state
events = ValueDecider.decide(Commands::Increase.new, state)
new_state = events.reduce(state) { |state, event| ValueDecider.evolve(state, events)
```

You can also compose deciders:

```ruby
Left = Data.define(:value)
Right = Data.define(:value)

left = Decider.define do
  initial_state Left.new(value: 0)

  decide Commands::LeftCommand do |command, state|
    [Events::LeftEvent.new(value: command.value)]
  end

  evolve Events::LeftEvent do |state, event|
    state.with(value: state.value + 1)
  end

  terminal? do |state|
    state <= 0
  end
end

right = Decider.define do
  initial_state Right.new(value: 0)

  decide Commands::RightCommand do |command, state|
    [Events::RightEvent.new(value: command.value)]
  end

  evolve Events::RightEvent do |state, event|
    state.with(value: state.value + 1)
  end

  terminal? do |state|
    state <= 0
  end
end

Composition = Decider.compose(left, right)

state = Composition.initial_state
#> #<data left=#<data Left value=0>, right=#<data Right value=0>>

events = Composition.decide(Commands::LeftCommand.new(value: 1), state)
#> [#<data value=1>]

state = events.reduce(state, &Composition.method(:evolve))
#> #<data left=#<data value=1>, right=#<data value=0>>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/decider.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
