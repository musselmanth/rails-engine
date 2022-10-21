class ItemSerializer
  include JSONAPI::Serializer
  include EmptyObjectSerializer

  attributes :name,
             :description,
             :unit_price,
             :merchant_id

  
end