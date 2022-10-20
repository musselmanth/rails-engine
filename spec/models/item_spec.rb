require 'rails_helper'

RSpec.describe Item do
  it { should belong_to :merchant }
  it { should have_many :invoice_items }
  it { should have_many(:invoices).through(:invoice_items) }
  
  it { should validate_presence_of :name }
  it { should validate_presence_of :description }
  it { should validate_presence_of :unit_price } 
  it { should validate_numericality_of :unit_price }

  it 'destroys any invoices that are empty after destruction' do
    invoice_1 = create(:invoice)
    invoice_2 = create(:invoice)
    item_1 = create(:item)
    item_2 = create(:item)
    invoice_1.items << [item_1, item_2]
    invoice_2.items << item_1

    item_1.destroy!
    expect(Invoice.all).to eq([invoice_1])
  end

  it 'returns a name search result' do
    item_1 = create(:item, name: "alice")
    item_2 = create(:item, name: "boop")
    item_3 = create(:item, name: "chad")

    result = Item.name_search("boop", 1)

    expect(result).to eq(item_2)
  end

  it 'returns a name with a partial search result' do
    item_1 = create(:item, name: "alice")
    item_2 = create(:item, name: "boopbeep")
    item_3 = create(:item, name: "chad")

    result = Item.name_search("ch", 1)

    expect(result).to eq(item_3)
  end

  it 'returns the fist alphabetically with multiple results' do
    item_1 = create(:item, name: "bbc")
    item_2 = create(:item, name: "abc")
    item_3 = create(:item, name: "cbc")

    result = Item.name_search("bc", 1)

    expect(result).to eq(item_2)
  end

  it 'can return multiple / all results in alphabetical order' do
    item_1 = create(:item, name: "bac")
    item_2 = create(:item, name: "cbc")
    item_3 = create(:item, name: "abc")

    result = Item.name_search("bc")

    expect(result).to eq([item_3, item_2])
  end

  it 'alphabetical order case 2' do
    item_1 = create(:item, name: "bac")
    item_2 = create(:item, name: "abc")
    item_3 = create(:item, name: "cbc")

    result = Item.name_search("bc")

    expect(result).to eq([item_2, item_3])
  end

  it 'name search case insensitive' do
    item_1 = create(:item, name: "Turing")
    item_2 = create(:item, name: "Ring World")
    item_3 = create(:item, name: "no")

    result = Item.name_search("ring")
    
    expect(result).to eq([item_2, item_1])
  end

end