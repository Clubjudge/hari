module Hari
  module Keys

    TYPES = %w(string list hash set sorted_set)

    autoload :Key,       'hari/keys/key'
    autoload :Hash,      'hari/keys/hash'
    autoload :List,      'hari/keys/list'
    autoload :Set,       'hari/keys/set'
    autoload :SortedSet, 'hari/keys/sorted_set'
    autoload :String,    'hari/keys/string'

  end
end
