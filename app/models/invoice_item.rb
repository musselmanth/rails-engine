class InvoiceItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :item
  
  around_destroy :destroy_empty_invoice

  private

  def destroy_empty_invoice
    inv_to_destroy = invoice
    yield
    inv_to_destroy.destroy if inv_to_destroy.invoice_items.empty?
  end

end