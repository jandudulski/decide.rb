# Infra

## In memory

```ruby
require "decider/in_memory"

GLOBAL = Decider::InMemory.new(MyDecider)

# returns list of events
GLOBAL.handle(command)

# returns current state
GLOBAL.state
```
