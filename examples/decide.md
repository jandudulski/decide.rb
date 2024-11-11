# Decide

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

Raise error when using `decide!`:

```ruby
decider.decide! :unknown, decider.initial_state
#> raise ArgumentError, Unknown command
```

## Commands

Commands can be primitives like symbols:

```ruby
decider = Decider.define do
  initial_state :initial

  decide :start do |command, state|
    case state
    in :initial, :stopped
      [:started]
    else
      []
    end
  end

  decide :stop do |command, state|
    case state
    in :started
      [:stopped]
    else
      []
    end
  end
end
```

Or any classes like [Dry::Struct](https://dry-rb.org/gems/dry-struct/) or [Data](https://rubyapi.org/3.3/o/data):

```ruby
Start = Data.define(:value)
Stop = Data.define

decider = Decider.define do
  initial_state :initial

  decide Start do |command, state|
    case state
    in :initial, :stopped
      [:started, command.value]
    else
      []
    end
  end

  decide Stop do |command, state|
    case state
    in :started
      [:stopped]
    else
      []
    end
  end
end
```

