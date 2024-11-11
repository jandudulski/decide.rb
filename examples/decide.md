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
