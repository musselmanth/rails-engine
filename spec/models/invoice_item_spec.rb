require 'rails_helper'

RSpec.describe InvoiceItem do
  it { should belong_to :invoice }
  it { should belong_to :item }
end