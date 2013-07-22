require 'redis'
require 'redis/namespace'
require 'active_model'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/string/inflections'
require 'yajl'
require 'erb'
require 'ostruct'

require 'hari/version'
require 'hari/configuration'
require 'hari/errors'
require 'hari/entity'
require 'hari/node'
require 'hari/relationship'
require 'hari/script'

module Hari
  extend self
  extend Configuration

  def node(arg)
    type, id = node_type(arg), node_id(arg)
    node = Node.new(model_id: id)
    node.instance_variable_set '@node_type', type
    node
  end

  def node_id(model)
    case model
    when ::String
      model.split('#').last
    when ::Hash
      model.first[1]
    else
      model.id
    end
  end

  def node_type(model)
    case model
    when ::String
      model.split('#').first
    when ::Hash
      model.first[0]
    else
      model.class.to_s.underscore.split('/').last
    end
  end

  def relation!(type, from, target)
    from_type   = from.class.to_s.underscore
    target_type = target.class.to_s.underscore

    Relationship.create type, "#{from_type}##{from.id}", "#{target_type}##{target.id}"
  end

end
