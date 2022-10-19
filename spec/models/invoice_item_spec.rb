require 'rails_helper'

RSpec.describe InvoiceItem do
  it { should belong_to :invoice }
  it { should belong_to :item }

  it 'should destroy an invoice upon destroyal if invoice is empty' do
    invoice_1 = create(:invoice)
    invoice_2 = create(:invoice)
    invoice_item_1 = create(:invoice_item, invoice: invoice_1)
    invoice_item_2 = create(:invoice_item, invoice: invoice_1)
    invoice_item_3 = create(:invoice_item, invoice: invoice_2)

    invoice_item_1.destroy!
    expect(Invoice.all).to match_array([invoice_1, invoice_2])

    invoice_item_2.destroy!
    expect(Invoice.all).to match_array([invoice_2])

    invoice_item_3.destroy!
    expect(Invoice.all).to match_array([])
  end
end