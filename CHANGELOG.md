# 0.5.3

* Add shortcut for evolving:

```ruby
# this three are the same now
[event, event].reduce(state) { |s, e| decider.evolve(s, e) }
[event, event].reduce(state, &decider.method(:evolve))

# new
[event, event].reduce(state, &decider.evolve)
```

# 0.5.2

* Add `dimap_on_event` extension that takes procs that maps event in and out and returns a new decider

```ruby
inner = Decider.define do
  initial_state 0

  decide :increase do
    :increased
  end

  evolve :increased do
    state + 1
  end
end

outer = decider.dimap_on_event(
  fl: ->(event) { event.to_sym },
  fr: ->(event) { event.to_s }
)

outer.decide(:increase, 0)
# => "increased"

outer.evolve(0, "increased")
# => 1
```

# 0.5.1

* Add `dimap_on_state` extension that takes procs that maps state in and out and returns a new decider

```ruby
inner = Decider.define do
  initial_state :symbol
end
inner.initial_state
# => :symbol

outer = decider.dimap_on_state(
  fl: ->(state) { state.to_sym },
  fr: ->(state) { state.to_s }
)
outer.initial_state
# => "symbol"

# under the hood it will run inner.decide(:command, :symbol)
outer.decide(:command, "symbol")
```

# 0.5.0

* Support pattern matching for commands and events
* Support passing state to decider and evolve matchers
* Remove explicit arguments for handlers
* Remove redundant bang methods - raise error in catch-all if needed
* Add Left|Right value wrappers for composition
* Use `emit` to return events in `decide`

# 0.4.1

* `define` returns new class, not object

# 0.4.0

* Accept more data structures for commands and events

# 0.3.0

* Rename `Decider.state` to `Decider.initial_state`
* Allow to use anything as state
* Use tuple-like array for composition
* Do not raise error when deciding unknown command
* Do not raise error when evolving unknown event

# 0.2.0

* Added `terminal?` function
* `Decider.compose(left, right)`

# 0.1.0

* Initial release
