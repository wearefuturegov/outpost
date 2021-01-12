class CostOptionSerializer < ActiveModel::Serializer
  attributes :option
  attributes :amount
  attributes :cost_type
end