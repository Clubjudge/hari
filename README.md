[![Build Status](https://travis-ci.org/Clubjudge/hari.png?branch=master)](https://travis-ci.org/Clubjudge/hari)

## hari

Hari is a library to persist and get nodes and its relations in Redis, using different data structures depending on your need.

    Hari(user: 23).out(:follow).out(:activity).limit(25)

The query above will return the top `25` activities from all nodes user `23` follows.

### Relations

Creating a relation can be as simple as:

    Hari.relation! :follow, user, event

    # where user / event are:

    - objects with #id method (node representation will be class#id, like user#23)
    - strings with node_type#node_id
    - hash like { node_type => node_id }
    - a Hari::Node instance
