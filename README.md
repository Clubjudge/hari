[![Build Status](https://travis-ci.org/Clubjudge/hari.png?branch=master)](https://travis-ci.org/Clubjudge/hari)

## hari

Hari is a gem to make easier for objects handle their Redis' [lists](https://github.com/Clubjudge/hari#lists), [sets](https://github.com/Clubjudge/hari#sets), [sorted sets](https://github.com/Clubjudge/hari#sorted_sets) and [**relations**](https://github.com/Clubjudge/hari#relations). You can also store the [**nodes**](https://github.com/Clubjudge/hari#nodes) in Redis if you wish.

```ruby
user = User.new(id: 20)

Hari(user).set(:friends_ids) << 10   # REDIS: SADD hari:user#20:friends_ids 10
```

### The `Hari()` wrapper method

It returns a `Hari::Node` representation of the object passed so you can call all `Node` operations available in Hari. You can do:

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

### Nodes

### Relations

Hari uses the power of Redis data structures to create relations between nodes, allowing you to traverse nodes and its relations like a graph, doing for example:

```ruby
# this gets the last 20 comments from the entities the user#1 follows
Hari(user: 1).out(:follow).out(:comments).limit(20)
```

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
