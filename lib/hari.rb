require 'redis'
require 'redis/namespace'
require 'redis/connection/hiredis'
require 'active_model'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/string/inflections'
require 'yajl'
require 'erb'
require 'ostruct'
require 'digest/md5'

require 'hari/version'
require 'hari/configuration'
require 'hari/errors'

module Hari
  extend self

  autoload :Entity,        'hari/entity'
  autoload :Keys,          'hari/keys'
  autoload :Node,          'hari/node'
  autoload :Object,        'hari/object'
  autoload :Relation,      'hari/relation'
  autoload :Serialization, 'hari/serialization'

  extend Configuration
  extend Hari::Node::Queries

  # Builds a Hari::Node
  #
  # @param (see #Hari)
  #
  # @return [Hari::Node] the Hari node
  #
  def node(arg)
    type, id = node_type(arg), node_id(arg)
    node = Node.new(model_id: id)
    node.instance_variable_set '@node_type', type.to_s
    node
  end

  # Returns the node String representation ("type#id"),
  # given the model / representation received
  #
  # @param (see #Hari)
  #
  # @return [String]
  #
  def node_key(model)
    if type = node_type(model)
      "#{type}##{node_id(model)}"
    else
      node_id model
    end
  end

  # Returns the node id, given the model / representation received
  #
  # @param (see #Hari)
  #
  # @return [String, Fixnum]
  #
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

  # Returns the node type given the model / representation received
  #
  # @param (see #Hari)
  #
  # @return [String, nil] node type
  #
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

  # Creates or finds a relation named name from origin to target
  #
  # @param name [String, Symbol] the relation name
  #
  # @param origin [String, Hash, Hari::Node]
  #          the representation of the node where
  #          the relation has its origin
  #
  # @param target [String, Hash, Hari::Node]
  #          the representation of the node where
  #          the relation has its target
  #
  # @param attrs [Hash] { weight }
  #
  # @return [Hari::Relation] the created / found relation
  #
  def relation!(name, origin, target, attrs = {})
    Relation.create name, origin, target, attrs
  end

  # Removes the relation between origin and target named name
  #
  # @param name [String, Symbol] the relation name
  #
  # @param origin [String, Hash, Hari::Node]
  #          the representation of the node where
  #          the relation has its origin
  #
  # @param target [String, Hash, Hari::Node]
  #          the representation of the node where
  #          the relation has its target
  #
  # @return [Hari::Relation] the deleted relation
  #
  def remove_relation!(name, origin, target)
    relation!(name, origin, target).delete
  end

end

# Builds a Hari::Node
#
# @param arg [String, Symbol, Hash, Hari::Node, Hari::Entity, #id]
#          When String, defines node as in "type#id".
#          When Hash, as in { type: id }.
#
# @return [Hari::Node] the Hari node
#
def Hari(arg)
  Hari.node arg
end
