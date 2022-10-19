require 'rails_helper'

RSpec.describe Invoice do
  it { should have_many(:invoice_items).dependent(:destroy) }
  it { should have_many(:items).through(:invoice_items) }
  it { should belong_to :customer }
end