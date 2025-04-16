# Decide

## Match by command

```ruby
Command = Data.define(:value)
State = Data.define(:value)

decider = Decider.define do
  initial_state State.new(value: 5)

  decide Command do
    # emit events
    emit Event.new(
      value: command.value + state.value
    )
  end
end

decider.decide Command.new(value: 10), decider.initial_state
#> [#<data Event value=15>]
```

## Match by command and state

```ruby
decider = Decider.define do
  initial_state :turned_off

  decide :turn_on, :turned_off do
    emit :turned_on
  end

  decide :turn_off, :turned_on do
    emit :turned_off
  end
end

decider.decide :turn_on, decider.initial_state
#> [:turned_on]
decider.decide :turn_off, :turned_on
#> [:turned_off]
decider.decide :turn_on, :turned_on
#> []
```

## Match by pattern matching

State = Data.define(:status)
TurnOn = Data.define
TurnOff = Data.define

```ruby
decider = Decider.define do
  initial_state State.new(status: :turned_off)

  decide proc { [command, state] in [TurnOn, State(status: :turned_off)] } do
    emit :turned_on
  end

  decide proc { [command, state] in [TurnOff, State(status: :turned_on)] } do
    emit :turned_off
  end
end

decider.decide :turn_on, decider.initial_state
#> [:turned_on]
decider.decide :turn_off, :turned_on
#> [:turned_off]
decider.decide :turn_on, :turned_on
#> []
```

## Handling unknown commands

```ruby
decider = Decider.define do
  initial_state :initial
end
```

Return empty list of events (nothing changed) by default:

```ruby
decider.decide :unknown, decider.initial_state
#> []
```

If you want to raise error, define a catch-all as last one:

```ruby
decider = Decider.define do
  initial_state :initial

  decide proc { true } do
    raise ArgumentError, "Unknown command #{command}"
  end
end
decider.decide :unknown, decider.initial_state
#> Unknown command unknown (ArgumentError)
```

## Commands

Commands can be primitives like symbols:

```ruby
decider = Decider.define do
  initial_state :initial

  decide proc { [command, state] in [:start, :initial | :stopped] } do
    emit :started
  end

  decide proc { [command, state] in [:stop, :started] } do
    emit :stopped
  end
end

decider.decide :start, decider.initial_state
#> [:started]
decider.decide :stop, :started
#> [:stopped]
decider.decider :start, :started
#> []
```

Or any classes like [Dry::Struct](https://dry-rb.org/gems/dry-struct/) or [Data](https://rubyapi.org/3.3/o/data):

```ruby
Start = Data.define(:value)
Stop = Data.define

decider = Decider.define do
  initial_state :initial

  decide proc { [command, state] in [Start, :initial | :stopped] } do
    emit [:started, command.value]
  end

  decide proc { [command, state] in [Stop, :started] } do
    emit :stopped
  end
end

decider.decide Start.new(value: 10), decider.initial_state
#> [[:started, 10]]
decider.decide Stop.new, [:started, 10]
#> [:stopped]
```

## Emitting Events

Decide can emit 0, 1 or more events:

```ruby
decider = Decider.define do
  initial_state :initial

  decide :none do
    # noop
  end

  decide :one do
    emit :event
  end

  decide :multiple do
    emit :one
    emit :two
  end
end

decider.decide :none, decider.initial_state
#> []
decider.decide :one, decider.initial_state
#> [:event]
decider.decide :multiple, decider.initial_state
#> [:one, :two]
```
