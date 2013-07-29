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

module Hari
  extend self

  autoload :Entity,   'hari/entity'
  autoload :Keys,     'hari/keys'
  autoload :Node,     'hari/node'
  autoload :Relation, 'hari/relation'

  extend Configuration
  extend Hari::Node::Queries

  def node(arg)
    type, id = node_type(arg), node_id(arg)
    node = Node.new(model_id: id)
    node.instance_variable_set '@node_type', type.to_s
    node
  end

  def node_key(model)
    if type = node_type(model)
      "#{type}##{node_id(model)}"
    else
      node_id model
    end
  end

  def node_id(model)
    case model
    when ::String, ::Symbol
      model.to_s.split('#').last
    when ::Hash
      model.first[1]
    when Hari::Node
      model.model_id
    else
      model.id
    end
  end

  def node_type(model)
    case model
    when ::String, ::Symbol
      model.to_s.split('#').first
    when ::Hash
      model.first[0]
    when Hari::Node
      model.node_type
    when Hari::Entity
      nil
    else
      model.class.to_s.underscore.split('/').last
    end
  end

  def relation!(type, from, target)
    Relation.create type, from, target
  end

end

def Hari(arg)
  Hari.node arg
end
