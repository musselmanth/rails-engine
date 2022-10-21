class Item < ApplicationRecord
  include Pageable
  
  belongs_to :merchant
  has_many :invoice_items, dependent: :destroy
  has_many :invoices, through: :invoice_items

  validates_presence_of :name, :description, :unit_price
  validates_numericality_of :unit_price

  def self.name_search(search_query, limit = nil)
    result = where("name ILIKE ?", "%#{search_query}%").limit(limit).order(:name)
    limit == 1 ? result.first : result
  end

  def self.price_search(min_price = nil, max_price = nil, limit = nil)
    min_price ||= 0
    max_price ||= Float::INFINITY
    result = where("unit_price >= ? AND unit_price <= ?", min_price, max_price).limit(limit).order(:name)
    limit == 1 ? result.first : result
  end
end