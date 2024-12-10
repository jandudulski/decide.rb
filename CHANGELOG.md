# Unreleased

* Support pattern matching for commands and events
* Support passing state to decider and evolve matchers
* Remove explicit arguments for handlers
* Remove redundant bang methods - raise error in catch-all if needed
* Add Left|Right value wrappers for composition

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
