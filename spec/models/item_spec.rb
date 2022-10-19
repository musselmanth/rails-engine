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
end