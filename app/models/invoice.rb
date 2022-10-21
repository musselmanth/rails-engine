class Invoice < ApplicationRecord
  has_many :invoice_items, dependent: :destroy
  has_many :items, through: :invoice_items
  belongs_to :customer

  def self.delete_empty_invoices_in(invoice_ids)
    Invoice
      .left_joins(:invoice_items)
      .where('invoices.id IN (?) AND invoice_items.id IS NULL', invoice_ids)
      .destroy_all
  end
end