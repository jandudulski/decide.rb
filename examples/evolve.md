# Evolve

## Handling unknown events

```ruby
decider = Decider.define do
  initial_state :initial
end
```

Return state (nothing changed) by default:

```ruby
decider.evolve decider.initial_state, :unknown
#> :initial
```

Raise error when using `evolve!`:

```ruby
decider.evolve! decider.initial_state, :unknown
#> raise ArgumentError, Unknown event
```

## Events

Events can be primitives like symbols:

```ruby
decider = Decider.define do
  initial_state :initial

  evolve :started do |state, event|
    :started
  end

  evolve :stopped do |state, event|
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

  evolve Started do |state, event|
    State.new(speed: event.speed)
  end

  evolve Stopped do |state, event|
    State.new(speed: 0)
  end
end
```

