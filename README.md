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

Then it's possible to query the mutual friends between users:

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

To create a query to get followers of this artist, do:

```ruby
Hari(artist).in(:follow)
```

The call above returns a query expression. You can do:

```ruby
Hari(artist).in(:follow).limit(10) # just the last 10 followers
```

If you just want the nodes ids, not the node instances, you can do:

```ruby
Hari(event).in(:follow).nodes_ids!
```
