require 'rails_helper'

RSpec.describe Merchant do
  it { should have_many :items }

  it 'returns a single merchant matching name' do
    merchant_1 = create(:merchant, name: "name")
    merchant_2 = create(:merchant, name: "not")
    merchant_3 = create(:merchant, name: "not2")

    result = Merchant.name_search("name", 1)
    expect(result).to eq(merchant_1)
  end

  it 'resturns a merchant with a partial name search result' do
    merchant_1 = create(:merchant, name: "name")
    merchant_2 = create(:merchant, name: "not")
    merchant_3 = create(:merchant, name: "not2")

    result = Merchant.name_search("na", 1)
    expect(result).to eq(merchant_1)
  end

  it 'returns the first alphabetircally with multiple results' do
    merchant_1 = create(:merchant, name: "name_b")
    merchant_2 = create(:merchant, name: "name_a")
    merchant_3 = create(:merchant, name: "not2")

    result = Merchant.name_search("name", 1)
    expect(result).to eq(merchant_2)
  end

  it 'returns multiple results in alphabetical order' do
    merchant_1 = create(:merchant, name: "name_b")
    merchant_2 = create(:merchant, name: "name_a")
    merchant_3 = create(:merchant, name: "not2")

    result = Merchant.name_search("name")
    expect(result).to eq([merchant_2, merchant_1])
  end

  it 'name search case insensitive' do
    merchant_1 = create(:merchant, name: "nAMe_b")
    merchant_2 = create(:merchant, name: "name_a")
    merchant_3 = create(:merchant, name: "not2")

    result = Merchant.name_search("name")
    expect(result).to eq([merchant_1, merchant_2])
  end
end