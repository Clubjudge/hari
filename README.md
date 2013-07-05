[![Build Status](https://travis-ci.org/rodrigues/hari.png?branch=master)](https://travis-ci.org/rodrigues/hari)

## hari

Hari is a Ruby gem to persist nodes and it's relations in Redis, graph-wise, and generates Lua scripts to make fast queries to the graph, things like this one:

    Hari.node(user: 23).out(:follow).out(:activity).limit(25)
