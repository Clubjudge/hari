[![Build Status](https://travis-ci.org/Clubjudge/hari.png?branch=master)](https://travis-ci.org/Clubjudge/hari)

## hari

Hari is a ruby gem to make easier for Ruby objects handle their Redis' [`lists`](https://github.com/Clubjudge/hari#lists), [`sets`](https://github.com/Clubjudge/hari#sets), [`sorted_sets`](https://github.com/Clubjudge/hari#sorted_sets) and [**relations**](https://github.com/Clubjudge/hari#relations).

```ruby
user = User.new(id: 20)

Hari(user).set(:friends_ids) << 10   # REDIS: SADD hari:user#20:friends_ids 10
```

### The `Hari()` wrapper

It returns a `Hari::Node` representation of the object passed. You can do:

```ruby
class User
  attr_reader :id   # might be an ActiveRecord::Base or whatever object responds to #id
end

user = User.find(20)

# all examples below work
Hari(user)
Hari('user#30')
Hari(user: 30)

=> #<Hari::Node:0x007f90f2a9d460 @model_id=1, @node_type="user">
```

### Lists

### Sets

### Sorted Sets

### Relations

Creating a relation can be as simple as:

```ruby
Hari.relation! :follow, user, event
```

To remove a relation, do:

```ruby
Hari.remove_relation! :follow, user, event
```

To list all nodes that follow an event:

```ruby
Hari(event).in(:follow).nodes
```

The above query will return a query object (lazy evaluation). To return the actual data, you need to call `to_a`, or `nodes!`.

If you just want the nodes ids, not the node instances, you can do:

```ruby
Hari(event).in(:follow).nodes_ids!
```
