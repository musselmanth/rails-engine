class InvoiceItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :item

  before_destroy { @invoice = invoice }
  after_destroy { @invoice.destroy if @invoice.invoice_items.empty? }
end