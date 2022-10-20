class MerchantSerializer
  include JSONAPI::Serializer
  include EmptyObjectSerializer

  attributes :name  

end