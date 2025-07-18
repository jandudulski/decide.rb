# 0.7.0

* Add reactor that can react to action results and issue actions

```ruby
ActionResult = Data.define(:value)
Action = Data.define(:value)

reactor = Reactor.define do
  react :action_result do
    issue :action
    issue :another_action
  end

  react proc { action_result in ActionResult(value: 42) } do
    issue Action.new(value: "the answer")
  end

  react ActionResult do
    issue Action.new(value: action_result.value)
  end
end

reactor.react(:action_result)
# => [:action, :another_action]
reactor.react(ActionResult.new(value: 42)
# => #<data Action value="the answer">
reactor.react(ActionResult.new(value: 1)
# => #<data Action value=1>
```

* Add `lmap_on_action_result` extension to reactor
* Add `rmap_on_action` (aliased to `map_on_action`) extensions to reactor
* Add `combine_with_decider` extension to reactor

```ruby
decider = Decider.define do
  initial_state 0

  decide :action do
    emit :result
  end

  decide :another_action do
    emit :another_result
  end
end

reactor = Decider::Reactor.define do
  react :result do
    issue :another_action
  end
end

decider = reactor.combine_with_decider(decider)
decider.decide(:action)
# => [:result, :another_result]
```

# 0.6.2

* Add `many` extension that takes a decider and manage many instances

```ruby
deciders = Decider.many(decider)
# or
deciders = decider.many

deciders.initial_state
# => {}

deciders.decide([id, command], state)
# => [[id, event], [id, event]]

deciders.evolve(state, [id, event])
# => state
```

# 0.6.1

* Add `apply` extension for creating applicatives

```ruby
decider = Decider.map(fn.curry, deciderx)
decider = Decider.apply(decider, decidery) 
decider = Decider.apply(decider, deciderz)
# or
deciderx.map(fn.curry).apply(decidery).apply(deciderz)
```

# 0.6.0

* All extensions takes decider as last argument

```ruby
# Before
Decider.dimap_on_state(decider, fl:, fr:)
Decider.dimap_on_event(decider, fl:, fr:)
Decider.lmap_on_event(decider, fn)
Decider.lmap_on_command(decider, fn)
Decider.lmap_on_state(decider, fn)
Decider.rmap_on_event(decider, fn)
Decider.rmap_on_state(decider, fn)

# After
Decider.dimap_on_state(fl, fr, decider)
Decider.dimap_on_event(fl, fr, decider)
Decider.lmap_on_event(fn, decider)
Decider.lmap_on_command(fn, decider)
Decider.lmap_on_state(fn, decider)
Decider.rmap_on_event(fn, decider)
Decider.rmap_on_state(fn, decider)
```

# 0.5.5

* Add `lmap_on_command` extension that takes proc that maps command and returns a new decider

```ruby
decider = Decider.define do
  initial_state 0

  decide :increase do
    emit :increased
  end
end

lmap = decider.lmap_on_command(->(command) { command.to_sym })
lmap.decide("increase", 0)
# => [:increased]
```

* Add `map` extension that works the same way as `rmap_on_state` but `Decider.map` takes function first

```ruby
# equivalent
Decider.rmap_on_state(decider, fn)
Decider.map(fn, decider)
decider.rmap_on_state(fn)
decider.map(fn)
```

* Add `map2` extension that takes function with two arguments and two deciders and returns a decider:

```ruby
dx = Decider.define do
  initial_state({score: 0})

  decide :score do
    emit :scored
  end

  evolve :scored do
    {score: state[:score] + 1}
  end
end

dy = Decider.define do
  initial_state({time: 0})

  decide :tick do
    emit :ticked
  end

  evolve :ticked do
    {time: state[:time] + 1}
  end
end

decider = Decider.map2(
  ->(sx, sy) { {score: sx[:score], time: sy[:time]} }, dx, dy
)

decider.initial_state
# => {score: 0, time: 0}
decider.decide(:score, decider.initial_state)
# => [:scored]
decider.decide(:tick, decider.initial_state)
# => [:ticked]
decider.evolve(decider.initial_state, :scored)
# => {score: 1, time: 0}
decider.evolve(decider.initial_state, :ticked)
# => {score: 0, time: 1}
```

# 0.5.4

* Add `lmap_on_event` and `rmap_on_event` extensions that takes proc that maps event in or out and returns a new decider

```ruby
decider = Decider.define do
  initial_state 0

  decide :increase do
    emit :increased
  end

  evolve :increased do
    state + 1
  end
end

lmap = decider.lmap_on_event(->(event) { event.to_sym })
lmap.evolve(0, "increased")
# => 1

rmap = decider.rmap_on_event(->(event) { event.to_s })
rmap.decide(:increase, 0)
# => "increased"
```

* Add `lmap_on_state` and `rmap_on_state` extensions that takes proc that maps state in or out and returns a new decider

```ruby
decider = Decider.define do
  initial_state :symbol

  decide :command, :state do
    emit :called
  end

  evolve :state, :called do
    :new_state
  end
end
decider.initial_state
# => :symbol

lmap = decider.lmap_on_state(
  ->(state) { state.to_sym }
)
lmap.initial_state
# => :symbol
lmap.decide(:command, "symbol")
# => [:called]
lmap.evolve("symbol", :called)
# => :new_state

rmap = inner.rmap_on_state(
  ->(state) { state.to_s }
)
rmap.initial_state
# => "symbol"
rmap.decide(:command, :symbol)
# => [:called]
rmap.evolve(:symbol, :called)
# => "new_state"
```

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
    emit :increased
  end

  evolve :increased do
    state + 1
  end
end

outer = inner.dimap_on_event(
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

outer = inner.dimap_on_state(
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
