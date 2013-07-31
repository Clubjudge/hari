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

If you do

```ruby
Hari('user#42').list(:comments)
```

You get a `Hari::Keys::List` instance, with methods to work with the `hari:user#42:comments` Redis list.

But if call it with the hashbang `!`

```ruby
Hari('user#42').list!(:comments)
```

You get all the members in this list instead. Let's go to the operations you can do with lists in Hari:

```ruby

comments = Hari('user#42').list(:comments)

comments.count  # also comments.size or comments.length       redis LLEN
comments.empty?
comments.one?
comments.many?

comments.first                                              # redis LINDEX
comments.last

# comment at position 4
comments[4]  # also comments.at(4) or comments.index(4)

# comments between positions 3 and 5:
comments[3, 5] # also comments[3..5] or comments.range(3, 5)  redis LRANGE

comments.from(7) # comments from position 7 to end of list

comments.to(5)   # comments from start of list to position 5

comments.members # both list all members in a list

comments.include?('trololol') # or comments.member?('trololol')
                              # expensive for a list, gets all members first



comments[6] = 'Good!' # sets element in position 6          # redis LSET


comments.rpush 'lol'                                        # redis RPUSH (append)
comments.add 'omg'
comments.push 'zomg'
comments << 'LOL'


comments.lpush 'First!'                                     # redis LPUSH (prepend)


comments.insert 'LOL', 'OMG'
comments.insert_after 'LOL', 'OMG'  # inserts OMG after LOL   redis LINSERT AFTER

comments.insert_before 'LOL', 'OMG' # inserts OMG before LOL  redis LINSERT BEFORE


comments.delete 'LOL' # deletes all ocurrences of LOL         redis LREM
comments.delete 'LOL', 2 # deletes first 2 ocurrences of LOL

comments.pop                                                # redis RPOP
comments.rpop  # deletes and brings last element in list

comments.shift                                              # redis LPOP
comments.lpop  # deletes and brings first element in list
```

### Sets

If you do

```ruby
Hari('user#42').set(:friends_ids)
```

You get a `Hari::Keys::Set` instance, with methods to work with the `hari:user#42:friends_ids` Redis set.

But if call it with the hashbang `!`

```ruby
Hari('user#42').set!(:friends_ids)
```

You get all the members in this set instead. Let's go to the operations you can do with sets in Hari:

```ruby

friends = Hari('user#42').set(:friends_ids)

friends.count # also friends.size or friends.length   redis SCARD
friends.empty?
friends.one?
friends.many?

friends.include?(10) # also friends.member?(10)       redis SISMEMBER

# all members
friends.members                                     # redis SMEMBERS

# random members
friends.rand
friends.rand(3)                                     # redis SRANDMEMBER

friends.add 30, 40, 50                              # redis SADD
friends << 60

friends.delete 40, 50                               # redis SREM

# deletes and return a random element
friends.pop                                         # redis SPOP


other_friends = Hari('user#43').set(:friends_ids)
friends & other_friends                             # redis SINTER
friends.intersect(other_friends)

friends - other_friends                             # redis SDIFF
friends.diff(other_friends)
```

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
