FactoryBot.define do
  factory :invoice do
    customer
    status { rand(3) }
  end
end