module Pageable
  extend ActiveSupport::Concern

  class_methods do
    def get_page(per_page, page)
      per_page ||= 20
      page ||= 1
      limit(per_page.to_i).offset((page.to_i - 1) * per_page.to_i)
    end
  end

end