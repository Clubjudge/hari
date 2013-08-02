[![Build Status](https://travis-ci.org/Clubjudge/hari.png?branch=master)](https://travis-ci.org/Clubjudge/hari)

# Hari

## Mile-high view

**Hari** is a tool to abstract complex relationships between **Ruby** objects onto **Redis** data structures. It allows for expressive querying of those relationships as well, in an easy way. It is mostly geared towards typical social networking concepts like news feeds, activity logs, friends of friends, mutual friends, and so on.

## Basic concepts

Hari embraces normal objects, and allows 2 major modes of operation: abstraction of Redis operations, and actual relationship creation and querying.

### Direct abstraction of Redis operations (lists, sets, sorted sets, etc)

Imagine this `User` model class:

```ruby
class User

  attr_reader :id

  def initialize(id)
    @id = id
  end

end
```

You can create a **set** to store the user relation with his friends:

```ruby
user = User.new(20)

Hari(user).set(:friends_ids) << 10   # REDIS: SADD hari:user#20:friends_ids 10
```

It's possible now to query the mutual friends between users:

```ruby
Hari(user: 20).set(:friends_ids) & Hari(user: 30).set(:friends_ids)

=> ["10", "25", "40"]
```

By now, you're probably wandering what the `Hari()` method does. It accepts an object like `user` as a parameter, or an identification of this object like `"user#20"`, or even `{user: 30}` and returns a `Hari::Node` representation of the object referenced so you can call all operations available in Hari.

#### Lists

Let's say every user will keep their comments in a linked list. If you do:

```ruby
comments = Hari('user#42').list(:comments)

=> #<Hari::Keys::List:0x007fcefb130cf0>
```

You get an object to call then Redis `list` operations. But if you want all the list members instead, call it with the hashbang `!`

```ruby
Hari('user#42').list!(:comments)

=> ["First!", "OMG", "LOL"]
```

If you want just the count of comments, there's no need to fetch all comments from Redis first. Call this instead, it's faster:

```ruby
comments.count  # also .size or .length

comments.empty?
comments.one?
comments.many?
```

To get comments at specific positions in the list, you can do:

```ruby
comments.first
comments.last

# comment at position 4
comments[4]  # also .at(4) or .index(4)

# comments between positions 3 and 5:
comments[3, 5] # also [3..5] or .range(3, 5)

comments.from(7) # comments from position 7 to end of list

comments.to(5)   # comments from start of list to position 5
```

More options to work with the comments list:

```ruby
comments.members # both list all members in a list

comments.include?('trololol') # or .member?('trololol')
                              # expensive for a list, gets all members first



comments[6] = 'Good!' # sets element in position 6


# append to list

comments.rpush 'lol'
comments.add 'omg'
comments.push 'zomg'
comments << 'LOL'

# prepends to list
comments.lpush 'First!'


comments.insert 'LOL', 'OMG'
comments.insert_after 'LOL', 'OMG'  # inserts OMG after LOL

comments.insert_before 'LOL', 'OMG' # inserts OMG before LOL


comments.delete 'LOL' # deletes all ocurrences of LOL
comments.delete 'LOL', 2 # deletes first 2 ocurrences of LOL

comments.pop
comments.rpop  # deletes and brings last element in list

comments.shift
comments.lpop  # deletes and brings first element in list
```

#### Sets

We're gonna keep the friends ids in a set like this:

```ruby
friends = Hari('user#42').set(:friends_ids)

=> #<Hari::Keys::Set:0x007fb5c45ae1b0>
```

This returns an object to call then Redis `set` operations. But if you want all the set members instead, call it with the hashbang `!`

```ruby
Hari('user#42').set!(:friends_ids)

=> ["10", "30"]
```

Let's go to the operations you can do with sets in Hari:

```ruby

friends.count # also .size or .length
friends.empty?
friends.one?
friends.many?

friends.include?(10) # also friends.member?(10)

# all members
friends.members

# random members
friends.rand
friends.rand(3)

friends.add 30, 40, 50
friends << 60

friends.delete 40, 50

# deletes and return a random element
friends.pop


other_friends = Hari('user#43').set(:friends_ids)
friends & other_friends
friends.intersect(other_friends)

friends - other_friends
friends.diff(other_friends)
```

#### Sorted Sets

If you want to have friends sorted by some weight (say, BFF: 100, family: 80, colleague: 40, …), you can use a sorted_set for that.

```ruby
friends = Hari('user#42').sorted_set(:friends)

=> #<Hari::Keys::SortedSet:0x007fb5c42a6df0>
```

This returns an object to call then Redis `sorted_set` operations. But if you want all the sorted set members instead, call it with the hashbang `!`

```ruby
Hari('user#42').sorted_set!(:friends_ids)

=> ["bill", "john", "mark"]
```

These are the operations you can do with a sorted set in Hari:

```ruby
friends.add 10, 'john', 30, 'bill', 50, 'jack'
friends << [10, 'john', 30, 'bill', 50, 'jack']

friends.count # also .size or .length
friends.empty?
friends.one?
friends.many?


friends.delete 'bill', 'jack'


friends.score 'john'

friends.include? 'john'


friends.rank 'john' # also .ranking or .position

friends.revrank 'john' # also .reverse_ranking
                       # or   .reverse_position


friends.members
```

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
