FactoryBot.define do
  factory :item do
    merchant
    name {Faker::Commerce.product_name }
    description { Faker::Quote.yoda }
    unit_price { rand(100..15000) }
  end
end