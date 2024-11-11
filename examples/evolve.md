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
