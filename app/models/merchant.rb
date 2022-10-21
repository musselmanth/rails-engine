class Merchant < ApplicationRecord
  include Pageable
  
  has_many :items

  def self.name_search(search_query, limit = nil)
    result = where("name ILIKE ?", "%#{search_query}%").limit(limit).order(:name)
    limit == 1 ? result.first : result
  end
end