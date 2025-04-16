# Evolve

## Match by event

```ruby
Event = Data.define(:value)

decider = Decider.define do
  initial_state :initial

  evolve Event do
    event.value
  end
end

decider.evolve decider.initial_state, Event.new(value: :changed)
#> :changed
```

## Match by state and event

```ruby
decider = Decider.define do
  initial_state :turned_off

  evolve :turned_on, :turned_off do
    event
  end

  evolve :turned_off, :turned_on do
    event
  end
end

decider.evolve decider.initial_state, :turned_on
#> :turned_on
decider.evolve :turned_on, :turned_off
#> :turned_off
decider.evolve :turned_on, :unknown
#> :turned_on
```

## Match by pattern matching

```ruby
State = Data.define(:value)
Event = Data.define(:value)

decider = Decider.define do
  initial_state State.new(value: :turned_off)

  evolve proc { [state, event] in [State(value: :turned_off), Event(value: :turned_on)] } do
    state.with(value: event.value)
  end
end

decider.evolve decider.initial_state, Event.new(value: :turned_on)
#> #<data State value=:turned_on>
decider.evolve decider.initial_state, :unknown
#> #<data State value=:turned_off>
```

## Handling unknown events

```ruby
decider = Decider.define do
  initial_state :initial
end

decider.decide decider.initial_state, :initial
#> :initial
```

If you want to raise error, define a catch-all as last one:

```ruby
decider = Decider.define do
  initial_state :initial

  evolve proc { true } do
    raise ArgumentError, "Unknown event #{event}"
  end
end
decider.evolve decider.initial_state, :unknown
#> Unknown event unknown (ArgumentError)
```

## Events

Events can be primitives like symbols:

```ruby
decider = Decider.define do
  initial_state :initial

  evolve :started do
    :started
  end

  evolve :stopped do
    :stopped
  end
end
```

Or any classes like [Dry::Struct](https://dry-rb.org/gems/dry-struct/) or [Data](https://rubyapi.org/3.3/o/data):

```ruby
State = Data.define(:speed)
Started = Data.define(:speed)
Stopped = Data.define

decider = Decider.define do
  initial_state State.new(speed: 0)

  evolve State, Started do
    state.with(speed: event.speed)
  end

  evolve State, Stopped do
    State.new(speed: 0)
  end
end
```

## Calculate state

In most cases you want to take a collection of events and reduce them with `evolve` to calculate the state, like:

```ruby
decider = Decider.define do
  initial_state 0

  evolve :increased do
    state + 1
  end
end

[:increased, :increased].reduce(decider.initial_state) { |state, event| decider.evolve(state, event) }
#> 2
```

You can shortcut that with `&`:

```ruby
[:increased, :increased].reduce(decider.initial_state, &decider.method(:evolve))
#> 2
[:increased, :increased].reduce(decider.initial_state, &decider.evolve)
#> 2
```
