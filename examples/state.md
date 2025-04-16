# State examples

## Data

```ruby
State = Data.define(:value)

decider = Decider.define do
  initial_state State.new(value: 0)

  decide Commands::Command do
    emit Events::Event.new(value: command.value)
  end

  evolve Events::Event do
    state.with(value: state.value + 1)
  end
end
```

## Primitive

```ruby
decider = Decider.define do
  initial_state :turned_off

  decide Commands::TurnOn, :turned_off do
    emit Events::TurnedOn.new
  end

  decide Commands::TurnOff, :turned_on do
    emit Events::TurnedOff.new
  end

  evolve Events::TurnedOn do
    :turned_on
  end
end
```

## List

```ruby
decider = Decider.define do
  initial_state []

  decide Commands::Command, [] do
    emit Events::Event.new(value: command.value)
  end

  evolve Events::Event do
    state + [event]
  end
end
```
