class CostOptionSerializer < ActiveModel::Serializer
  attributes :id, :option, :amount, :cost_type
end
