require 'rails_helper'

RSpec.describe "Merchants API" do

  context 'get merchants' do
    it 'sends a list of merchants' do
      create_list(:merchant, 5)

      get '/api/v1/merchants'

      expect(response).to be_successful

      parsed_response = JSON.parse(response.body, symbolize_names: true)

      expect(parsed_response).to have_key(:data)
      expect(parsed_response[:data]).to be_an(Array)
      expect(parsed_response[:data].length).to eq(5)

      merchants = parsed_response[:data]

      merchants.each do |merchant|
        expect(merchant).to have_key(:id)
        expect(merchant[:id]).to be_a(String)
        expect(merchant).to have_key(:type)
        expect(merchant[:type]).to eq("merchant")
        expect(merchant).to have_key(:attributes)
        expect(merchant[:attributes]).to be_a(Hash)
        expect(merchant[:attributes]).to have_key(:name)
        expect(merchant[:attributes][:name]).to be_a(String)
      end
    end

    it 'sends an empty data array if there are no merchants' do
      get '/api/v1/merchants'

      expect(response).to be_successful
      parsed_response = JSON.parse(response.body, symbolize_names: true)

      expect(parsed_response).to have_key(:data)
      expect(parsed_response[:data]).to be_an(Array)
      expect(parsed_response[:data].empty?).to be(true)
    end
  end

  context 'get single merchant' do

    it 'returns the merchant data' do
      merchant_model = create(:merchant)
      get "/api/v1/merchants/#{merchant_model.id}"

      expect(response).to be_successful

      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body).to have_key(:data)
      expect(response_body[:data]).to be_a(Hash)

      merchant = response_body[:data]

      expect(merchant).to have_key(:id)
      expect(merchant[:id]).to eq(merchant_model.id.to_s)
      expect(merchant[:type]).to eq("merchant")
      expect(merchant[:attributes]).to be_a(Hash)
      merch_attr = merchant[:attributes]
      expect(merch_attr).to have_key(:name)
      expect(merch_attr[:name]).to eq(merchant_model.name)
    end
  end
end