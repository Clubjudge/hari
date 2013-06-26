require 'redis'
require 'redis/namespace'
require 'active_model'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/object/try'
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

  def self.node(args = {})
    type, id = args.first
    node = Node.new(model_id: id)
    node.instance_variable_set '@node_type', type
    node
  end

  def self.relation!(type, args = {})
    from_type, from_id, to_type, to_id = args.to_a.flatten
    Relationship.create type, "#{from_type}##{from_id}", "#{to_type}##{to_id}"
  end

end
