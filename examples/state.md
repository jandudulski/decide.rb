# State examples

## Data

```ruby
State = Data.define(:value)

decider = Decider.define do
  initial_state State.new(value: 0)

  decide Commands::Command do |command, state|
    [Events::Event.new(value: command.value)]
  end

  evolve Events::Event do |state, event|
    state.with(value: state.value + 1)
  end
end
```

## Primitive

```ruby
decider = Decider.define do
  initial_state :turned_off

  decide Commands::TurnOn do |_command, state|
    case state
    in :turned_off
      [Events::TurnedOn.new]
    else
      []
    end
  end

  decide Commands::TurnOff do |_command, state|
    case state
    in :turned_on
      [Events::TurnedOn.new]
    else
      []
    end
  end

  evolve Events::TurnedOn do |_state, _event|
    :turned_off
  end
end
```

## List

```ruby
decider = Decider.define do
  initial_state []

  decide Commands::Command do |command, _state|
    [Events::Event.new(value: command.value)]
  end

  evolve Events::Event do |state, event|
    state = state + [event]
  end
end
```
