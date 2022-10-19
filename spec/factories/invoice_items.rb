FactoryBot.define do
  factory :invoice_item do
    item
    invoice
    quantity {rand(1..500)}
    unit_price { rand(100..15000) }
  end
end