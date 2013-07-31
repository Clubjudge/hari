[![Build Status](https://travis-ci.org/Clubjudge/hari.png?branch=master)](https://travis-ci.org/Clubjudge/hari)

## hari

Hari is a library to persist and get nodes and its relations in Redis, using different data structures depending on your need.

```ruby
Hari(user: 23).out(:follow).out(:activity).limit(25)
```

The query above will return the top `25` activities from all nodes user `23` follows.

### Relations

Creating a relation can be as simple as:

```ruby
Hari.relation! :follow, user, event
```

<sub>Both `user` and `event` can be a `Hari::Node` instance, an `ActiveRecord::Base` model or any object that responds to the `#id` method. Also a `"user#1"` string representation or a hash { user: 1 } are accepted, as just the model type and id are needed for this operation.</sub>

To remove a relation, do:

```ruby
Hari.remove_relation! :follow, user, event
```

To list all nodes that follow an event:

```ruby
Hari(event).in(:follow).nodes
```

The above query will return a query object (lazy evaluation). To return the actual data, you need to call `to_a`, or `nodes!`.

The `Hari()` method works as a wrapper to convert objects (`User<ActiveRecord::Base`, `'user#1'`, `{user: 1}`, etc) into a queryable `Hari::Node`.

If you just want the nodes ids, not the node instances, you can do:

```ruby
Hari(event).in(:follow).nodes_ids!
```
