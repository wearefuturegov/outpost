class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.from_hash(hash)
    h = hash.dup
    h.each do |key, value|
      case value.class.to_s
      when 'Array'
        next if key == "directories" # Ignore old array column 'directories' as not using this anymore and may cause errors
        next unless Object.const_defined?(key.camelize.singularize)
        h[key].map! { |e|
          Object.const_get(key.camelize.singularize).from_hash e }
      when 'Hash'
        next unless Object.const_defined?(key.camelize)
        h[key] = Object.const_get(key.camelize).from_hash value
      end
    end
    self.new h.except(*(h.keys - self.attribute_names))
  end
end
