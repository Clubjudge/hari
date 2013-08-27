[![Build Status](https://travis-ci.org/Clubjudge/hari.png?branch=master)](https://travis-ci.org/Clubjudge/hari)

# Hari

## Mile-high view

**Hari** is a tool to abstract complex relationships between **Ruby** objects onto **Redis** data structures. It allows for expressive querying of those relationships as well, in an easy way. It is mostly geared towards typical social networking concepts like news feeds, activity logs, friends of friends, mutual friends, and so on.

## Basic concepts

Hari embraces normal objects, and allows 2 major modes of operation: abstraction of Redis operations, and actual relationship creation and querying.

## Abstraction of Redis operations (lists, sets, sorted sets, etc)

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

Then it's possible, for instance, to query the mutual friends between users:

```ruby
Hari(user: 20).set(:friends_ids) & Hari(user: 30).set(:friends_ids)

=> ["10", "25", "40"]
```

By now, you're probably wandering what the `Hari()` method does. It accepts an object like `user` as a parameter, or an identification of this object like `"user#20"`, or even `{user: 30}` and returns a `Hari::Node` representation of the object referenced so you can call all operations available in Hari.

### [Lists](https://github.com/Clubjudge/hari/wiki/Lists), [Sets](https://github.com/Clubjudge/hari/wiki/Sets) and [Sorted Sets](https://github.com/Clubjudge/hari/wiki/Sorted-Sets) operations are available in the Wiki.

## Relationships

Hari uses the power of Redis data structures to create relations between objects, allowing you to traverse nodes and its relations like a graph.

```ruby
# this gets the last 20 comments from the entities the user#1 follows
Hari(user: 1).out(:follow).out(:comments).limit(20)
```

Creating a relation can be as simple as:

```ruby
Hari.relation! :follow, user, artist
```

To remove a relation, do:

```ruby
Hari.remove_relation! :follow, user, artist
```

Let's mount some queries:

```ruby
# artist followers
Hari(artist).in(:follow)

# entities that user follow
Hari(user).out(:follow)

# just the last 10 followers of artist
Hari(artist).in(:follow).limit(10)

# paginates from a score (timestamp.to_f),
# bringing the next 10 followers up from a last timestamp,
# (useful for pooling streams)
Hari(artist).in(:follow).limit(10).from(1375977470.382)

# paginates from a score down,
# bringing the previous 10 followers from a last timestamp
Hari(artist).in(:follow).limit(10).from(1375977470.382, :down)

# chaining relations between nodes
# last 10 entities to be followed by who user follows
Hari(user).out(:follow).out(:follow).limit(10)

# All users following artist
Hari(artist).in(:follow).type(:user)
```

All the calls above return a lazy query expression. The ruby code still didn't fetch the Redis backend, it's mounting a composable query.

Below there are some of the methods that make the query come to an end:

```ruby
# how many followers
Hari(artist).in(:follow).count
=> 2001

# returns all followers nodes ids
Hari(artist).in(:follow).nodes_ids!
=> ['artist#20', 'user#30', 'user#33']


# returns all followers instances of Hari::Node
# depends that you have the nodes persisted for each object
# this is the default implementation when you do .to_a
Hari(artist).in(:follow).nodes!

tiesto_followers   = Hari(artist: 21).in(:follow).type(:user)
daftpunk_followers = Hari(artist: 42).in(:follow).type(:user)

# count of common users following two artists
tiesto_followers.intersect_count(daft_punk_followers)
=> 6

# actual users ids following two artists
tiesto_followers.intersect(daft_punk_followers)
=> [17, 29, 3, 173, 919, 11]

# paginating through them (start + stop)
tiesto_followers.intersect(daft_punk_followers, 2, 5)
=> [3, 173, 919]

user_friends = Hari(user).out(:follow).type(:user)

# bringing all followers of artist, but user's friends first
tiesto_followers.sort_by user_friends
=> [883, 317, 211, 157, 163, 103, 47, 53, 7]

# paginating through them (offset + count)
tiesto_followers.sort_by user_friends, 3, 5
=> [157, 163, 103, 47, 53]
```
