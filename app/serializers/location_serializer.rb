
class LocationSerializer < ActiveModel::Serializer
    attribute :id
    attribute :name
    attribute :address_1
    attribute :city
    attribute :state_province
    attribute :postal_code
    attribute :country
    attribute :geometry
    attribute :mask_exact_address

    has_many :accessibilities

    def geometry
        return {
            type: "Point",
            coordinates: [object.longitude.to_f.round(2), object.latitude.to_f.round(2)]
        } if object.mask_exact_address
        object.geometry
    end

    def address_1
        return nil if object.mask_exact_address
        object.address_1
    end

    def postal_code
        if object.mask_exact_address and object.postal_code
        return UKPostcode.parse("W1A 2AB").outcode
        end
        object.postal_code
    end
end