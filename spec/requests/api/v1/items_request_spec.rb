require 'rails_helper'

RSpec.describe 'Items API' do

  context 'get items' do

    it 'returns a list of items' do
      create_list(:item, 10)

      get '/api/v1/items'

      expect(response).to be_successful

      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body).to have_key(:data)

      items = response_body[:data]

      expect(items).to be_an(Array)
      expect(items.length).to eq(10)

      items.each do |item|
        expect(item).to be_a Hash
        expect(item).to have_key(:id)
        expect(item[:id]).to be_a(String)
        expect(item).to have_key(:type)
        expect(item[:type]).to eq("item")
        expect(item).to have_key(:attributes)
        expect(item[:attributes]).to be_a(Hash)

        item_atts = item[:attributes]

        expect(item_atts).to have_key(:name)
        expect(item_atts[:name]).to be_a(String)
        expect(item_atts).to have_key(:description)
        expect(item_atts[:description]).to be_a(String)
        expect(item_atts).to have_key(:unit_price)
        expect(item_atts[:unit_price]).to be_a(Float)
      end
    end

    it 'returns an empty data array if there are no items' do
      get '/api/v1/items'

      expect(response).to be_successful
      parsed_response = JSON.parse(response.body, symbolize_names: true)

      expect(parsed_response).to have_key(:data)
      expect(parsed_response[:data]).to be_an(Array)
      expect(parsed_response[:data].empty?).to be(true)
    end

  end

  context 'get single item' do

    it 'returns an existing item succesfully' do
      item_model = create(:item)

      get "/api/v1/items/#{item_model.id}"

      expect(response).to be_successful

      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body).to be_a(Hash)
      expect(response_body).to have_key(:data)

      item = response_body[:data]
      expect(item).to be_a(Hash)
      expect(item).to have_key(:id)
      expect(item[:id]).to eq(item_model.id.to_s)
      expect(item).to have_key(:type)
      expect(item[:type]).to eq("item")
      expect(item).to have_key(:attributes)
      item_attr = item[:attributes]
      expect(item_attr).to have_key(:name)
      expect(item_attr[:name]).to eq(item_model.name)
      expect(item_attr).to have_key(:description)
      expect(item_attr[:description]).to eq(item_model.description)
      expect(item_attr).to have_key(:unit_price)
      expect(item_attr[:unit_price]).to eq(item_model.unit_price)
    end

    it 'returns an error if an item doesnt exists' do
      get "/api/v1/items/1"

      expect(response).to have_http_status(404)

      response_body = JSON.parse(response.body, symbolize_names: true)
      expected = { message: "your query could not be completed", errors: ["Couldn't find Item with 'id'=1"] }

      expect(response_body).to eq(expected)
    end
  end

  context 'create item' do
    
    it 'can create a successful item' do
      merchant = create(:merchant)
      item_params = ({
        name: "item name",
        description: "item description",
        unit_price: 150.00,
        merchant_id: merchant.id
      })
      headers = {"CONTENT_TYPE" => "application/json"}

      post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)

      expect(response).to be_successful
      expect(response).to have_http_status(201)

      item = Item.last
      expect(item.name).to eq(item_params[:name])
      expect(item.description).to eq(item_params[:description])
      expect(item.unit_price).to eq(item_params[:unit_price])
      expect(item.merchant_id).to eq(merchant.id)
    end

    it 'errors with missing params' do
      item_params = ({})
      headers = {"CONTENT_TYPE" => "application/json"}

      post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
      expect(response).to have_http_status(400)

      response_body = JSON.parse(response.body, symbolize_names: true)
      expected = {
        message: "your query could not be completed",
        errors: ["params are missing or invalid"]
      }
      
      expect(response_body).to eq(expected)
      expect(Item.last).to be(nil)
    end

    it 'errors with incorrect validation' do
      merchant = create(:merchant)
      item_params = ({
        name: "",
        description: "",
        unit_price: "",
        merchant_id: ""
      })
      headers = {"CONTENT_TYPE" => "application/json"}

      post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)

      expect(response).to have_http_status(400)

      response_body = JSON.parse(response.body, symbolize_names: true)
      expected = {
        message: "your query could not be completed",
        errors: [
            "Merchant must exist",
            "Name can't be blank",
            "Description can't be blank",
            "Unit price can't be blank",
            "Unit price is not a number"
        ]
      }

      expect(response_body).to eq(expected)
    end

    it 'errors with missing params' do
      merchant = create(:merchant)
      item_params = ({
        name: "item name",
        merchant_id: merchant.id
      })
      headers = {"CONTENT_TYPE" => "application/json"}

      post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)

      expect(response).to have_http_status(400)

      response_body = JSON.parse(response.body, symbolize_names: true)
      expected = {
        message: "your query could not be completed",
        errors: [
            "Description can't be blank",
            "Unit price can't be blank",
            "Unit price is not a number"
        ]
      }

      expect(response_body).to eq(expected)
    end
  end

  context 'update an item' do
    it 'can update an existing item' do
      item = create(:item)
      item_params = ({
        name: "item name",
        description: "item description",
        unit_price: 150.00,
      })
      headers = {"CONTENT_TYPE" => "application/json"}

      patch "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate(item: item_params)

      expect(response).to be_successful
      expect(response).to have_http_status(202)

      item.reload
      response_body = JSON.parse(response.body, symbolize_names: true)
      expected = {
        data: {
          id: item.id.to_s,
          type: "item",
          attributes: {
            name: item.name,
            description: item.description,
            unit_price: item.unit_price,
            merchant_id: item.merchant_id
          }
        }
      }

      expect(response_body).to eq(expected)
      expect(item.name).to eq(item_params[:name])
      expect(item.description).to eq(item_params[:description])
      expect(item.unit_price).to eq(item_params[:unit_price])
    end

    it 'errors if item not found' do
      item_params = ({
        name: "item name",
        description: "item description",
        unit_price: 150.00,
      })
      headers = {"CONTENT_TYPE" => "application/json"}

      patch "/api/v1/items/1", headers: headers, params: JSON.generate(item: item_params)

      expect(response).to have_http_status(404)
      
      response_body = JSON.parse(response.body, symbolize_names: true)
      expected = { message: "your query could not be completed", errors: ["Couldn't find Item with 'id'=1"] }

      expect(response_body).to eq(expected)
    end

    it 'errors if params missing' do
      item = create(:item)
      item_params = nil
      headers = {"CONTENT_TYPE" => "application/json"}
      patch "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate(item: item_params)

      expect(response).to have_http_status(400)
      
      response_body = JSON.parse(response.body, symbolize_names: true)
      expected = { message: "your query could not be completed", errors: ["params are missing or invalid"] }

      expect(response_body).to eq(expected)
    end

    it 'errors if validations incorrect' do
      item_1 = create(:item)
      item_2 = create(:item)
      item_1_params = ({
        unit_price: "test"
      })
      item_2_params = ({name: ""})
      headers = {"CONTENT_TYPE" => "application/json"}

      patch "/api/v1/items/#{item_1.id}", headers: headers, params: JSON.generate(item: item_1_params)

      expect(response).to have_http_status(400)
      
      response_body = JSON.parse(response.body, symbolize_names: true)
      expected = {
        message: "your query could not be completed",
        errors: ["Unit price is not a number"]
      }

      expect(response_body).to eq(expected)

      patch "/api/v1/items/#{item_2.id}", headers: headers, params: JSON.generate(item: item_2_params)      

      expect(response).to have_http_status(400)
      
      response_body = JSON.parse(response.body, symbolize_names: true)
      expected = {
        message: "your query could not be completed",
        errors: ["Name can't be blank"]
      }    

      expect(response_body).to eq(expected)
    end
  end

  context 'destroy item' do
    it 'can destroy an item' do
      items = create_list(:item, 2)

      expect(Item.last).to eq(items[1])

      delete "/api/v1/items/#{items[1].id}"
      
      expect(response).to have_http_status(204)
      expect(response.body).to eq("")
      expect(Item.last).to eq(items[0])
    end

    it 'errors if item cant be found' do
      delete "/api/v1/items/1"

      expect(response).to have_http_status(404)
      
      response_body = JSON.parse(response.body, symbolize_names: true)
      expected = {message: "your query could not be completed", errors: ["Couldn't find Item with 'id'=1"]}
    end
  end

  context 'item merchant' do
    it 'returns the items merchant' do
      merchant_model = create(:merchant)
      item = create(:item, merchant: merchant_model)
      get "/api/v1/items/#{item.id}/merchant"
      
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

    it 'returns error if item not found' do
      get "/api/v1/items/1/merchant"

      expect(response).to have_http_status(404)
      
      response_body = JSON.parse(response.body, symbolize_names: true)
      expected = {message: "your query could not be completed", errors: ["Couldn't find Item with 'id'=1"]}
    end
    
    context 'pagination' do
      before :each do
        @items = create_list(:item, 26)
      end

      let(:inv_params_error) {{message: "your query could not be completed", errors: ["params are missing or invalid"]}}

      it 'returns 20 by default' do
        get "/api/v1/items"
        
        results = JSON.parse(response.body, symbolize_names: true)[:data]
        expected = JSON.parse(ItemSerializer.new(@items[0..19]).to_json, symbolize_names: true)[:data]
        expect(results.length).to eq(20)
        expect(results).to eq(expected)
      end

      it 'returns remaining 6 on page 2' do
        get "/api/v1/items?page=2"
        results = JSON.parse(response.body, symbolize_names: true)[:data]
        expected = JSON.parse(ItemSerializer.new(@items[20..25]).to_json, symbolize_names: true)[:data]
        expect(results.length).to eq(6)
        expect(results).to eq(expected)
      end

      it 'returns number of results requested' do
        get "/api/v1/items?per_page=5"
        results = JSON.parse(response.body, symbolize_names: true)[:data]
        expect(results.length).to eq(5)

        get "/api/v1/items?per_page=5&page=6"
        results = JSON.parse(response.body, symbolize_names: true)[:data]
        expect(results.length).to eq(1)
      end

      it 'errors when params are negative' do
        get "/api/v1/items?per_page=-1"
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body, symbolize_names: true)).to eq(inv_params_error)
        get "/api/v1/items?per_page=-8&page=-9"
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body, symbolize_names: true)).to eq(inv_params_error)
        get "/api/v1/items?per_page=8&page=-1"
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body, symbolize_names: true)).to eq(inv_params_error)
        get "/api/v1/items?page=-5"
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body, symbolize_names: true)).to eq(inv_params_error)
        get "/api/v1/items?per_page=-8&page=5"
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body, symbolize_names: true)).to eq(inv_params_error)
      end

    end
  end

  context 'find one item' do

    let(:inv_search_error) {
      {
      message: "your query could not be completed",
      errors: ["invalid search parameters"]
      }
    }

    it 'returns a matching item' do
      item_model = create(:item, name: "beepboop")

      get "/api/v1/items/find?name=beepboop"

      expect(response).to be_successful

      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body).to be_a(Hash)
      expect(response_body).to have_key(:data)

      item = response_body[:data]
      expect(item).to be_a(Hash)
      expect(item).to have_key(:id)
      expect(item[:id]).to eq(item_model.id.to_s)
      expect(item).to have_key(:type)
      expect(item[:type]).to eq("item")
      expect(item).to have_key(:attributes)
      item_attr = item[:attributes]
      expect(item_attr).to have_key(:name)
      expect(item_attr[:name]).to eq(item_model.name)
      expect(item_attr).to have_key(:description)
      expect(item_attr[:description]).to eq(item_model.description)
      expect(item_attr).to have_key(:unit_price)
      expect(item_attr[:unit_price]).to eq(item_model.unit_price)
    end

    it 'returns empty data objec if no results' do
      item_1 = create(:item, unit_price: 3, name: "a")
      item_2 = create(:item, unit_price: 8, name: "b")

      get "/api/v1/items/find?name=c"

      expect(response).to be_successful
      expect(response).to have_http_status(200)
      response_body = JSON.parse(response.body, symbolize_names: true)
      expect(response_body).to eq({ data: {} })
    end

    it 'returns errors if string is blank' do
      item_model = create(:item, name: "beepboop")

      get "/api/v1/items/find?name="

      expect(response).to have_http_status(400)

      response_body = JSON.parse(response.body, symbolize_names: true)
      
      expect(response_body).to eq(inv_search_error)
    end

    it 'returns errors if min_price or max_price included in params' do
      item_model = create(:item, name: "beepboop")

      get "/api/v1/items/find?name=beepboop&min_price=55.5"

      expect(response).to have_http_status(400)

      get "/api/v1/items/find?name=beepboop&max_price=55.5"

      expect(response).to have_http_status(400)

      get "/api/v1/items/find?name=beepboop&min_price=8&max_price=55.5"

      expect(response).to have_http_status(400)

      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body).to eq(inv_search_error)
    end

    it 'returns error if no params' do
      get "/api/v1/items/find"

      expect(response).to have_http_status(400)

      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body).to eq(inv_search_error)
    end

    it 'returns error if min_price or max_price less than 0' do
      get("/api/v1/items/find?min_price=-10")

      expect(response).to have_http_status(400)

      get("/api/v1/items/find?max_price=-10")

      expect(response).to have_http_status(400)

      get("/api/v1/items/find?min_price=5&max_price=-8")

      expect(response).to have_http_status(400)

      get("/api/v1/items/find?min_price=-1&max_price=10")

      expect(response).to have_http_status(400)

      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body).to eq(inv_search_error)
    end

    it 'returns error if min price greater than max price' do
      get("/api/v1/items/find?min_price=10&max_price=5")

      expect(response).to have_http_status(400)

      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body).to eq(inv_search_error)
    end

    it 'returns first alphabetical above min price' do
      item_1 = create(:item, unit_price: 3, name: "a")
      item_2 = create(:item, unit_price: 8, name: "b")
      item_3 = create(:item, unit_price: 10, name: "d")
      item_4 = create(:item, unit_price: 11, name: "e")
      item_5 = create(:item, unit_price: 15, name: "c")
      item_6 = create(:item, unit_price: 18, name: "f")

      get("/api/v1/items/find?min_price=10")

      expect(response).to be_successful

      response_body = JSON.parse(response.body, symbolize_names: true)

      expected = {
        data: {
          id: item_5.id.to_s,
          type: "item",
          attributes: {
            name: "c",
            unit_price: item_5.unit_price,
            description: item_5.description,
            merchant_id: item_5.merchant_id
          }
        }
      }

      expect(response_body).to eq(expected)
    end
  end

  context 'find_all items' do

    let(:inv_search_error) {{message: "your query could not be completed", errors: ["invalid search parameters"]}}

    it 'errors for same reasons as find' do
      get "/api/v1/items/find_all?name="
      expect(response).to have_http_status(400)
      expect(JSON.parse(response.body, symbolize_names: true)).to eq(inv_search_error)
      get "/api/v1/items/find_all?name=beepboop&min_price=55.5"
      expect(response).to have_http_status(400)
      expect(JSON.parse(response.body, symbolize_names: true)).to eq(inv_search_error)
      get "/api/v1/items/find_all?name=beepboop&max_price=55.5"
      expect(response).to have_http_status(400)
      expect(JSON.parse(response.body, symbolize_names: true)).to eq(inv_search_error)
      get "/api/v1/items/find_all?name=beepboop&min_price=8&max_price=55.5"
      expect(response).to have_http_status(400)
      expect(JSON.parse(response.body, symbolize_names: true)).to eq(inv_search_error)
      get "/api/v1/items/find_all"
      expect(response).to have_http_status(400)
      expect(JSON.parse(response.body, symbolize_names: true)).to eq(inv_search_error)
      get "/api/v1/items/find_all?min_price=-10"
      expect(response).to have_http_status(400)
      expect(JSON.parse(response.body, symbolize_names: true)).to eq(inv_search_error)
      get "/api/v1/items/find_all?max_price=-10"
      expect(response).to have_http_status(400)
      expect(JSON.parse(response.body, symbolize_names: true)).to eq(inv_search_error)
      get "/api/v1/items/find_all?min_price=5&max_price=-8"
      expect(response).to have_http_status(400)
      expect(JSON.parse(response.body, symbolize_names: true)).to eq(inv_search_error)
      get "/api/v1/items/find_all?min_price=-1&max_price=10"
      expect(response).to have_http_status(400)
      expect(JSON.parse(response.body, symbolize_names: true)).to eq(inv_search_error)
      get "/api/v1/items/find_all?min_price=10&max_price=5"
      expect(response).to have_http_status(400)
      expect(JSON.parse(response.body, symbolize_names: true)).to eq(inv_search_error)
    end

    it 'returns empty data array if no results' do
      item_1 = create(:item, unit_price: 3, name: "a")
      item_2 = create(:item, unit_price: 8, name: "b")

      get "/api/v1/items/find_all?name=c"

      expect(response).to be_successful
      expect(response).to have_http_status(200)
      response_body = JSON.parse(response.body, symbolize_names: true)
      expect(response_body).to eq({ data: [] })
    end

    it 'returns all items greater than price in alph order' do
      item_1 = create(:item, unit_price: 3, name: "a")
      item_2 = create(:item, unit_price: 8, name: "b")
      item_3 = create(:item, unit_price: 10, name: "d")
      item_4 = create(:item, unit_price: 11, name: "e")
      item_5 = create(:item, unit_price: 15, name: "c")
      item_6 = create(:item, unit_price: 18, name: "f")

      get("/api/v1/items/find_all?min_price=10")

      expect(response).to be_successful

      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body).to have_key(:data)
      expect(response_body[:data]).to be_an(Array)
      expect(response_body[:data].length).to eq(4)
      expect(response_body[:data][0][:attributes][:name]).to eq("c")
      expect(response_body[:data][1][:attributes][:name]).to eq("d")
      expect(response_body[:data][2][:attributes][:name]).to eq("e")
      expect(response_body[:data][3][:attributes][:name]).to eq("f")
    end

    it 'returns all items less than price in alph order' do
      item_1 = create(:item, unit_price: 15, name: "a")
      item_2 = create(:item, unit_price: 16, name: "b")
      item_3 = create(:item, unit_price: 10, name: "d")
      item_4 = create(:item, unit_price: 4, name: "e")
      item_5 = create(:item, unit_price: 1, name: "c")
      item_6 = create(:item, unit_price: 2, name: "f")

      get("/api/v1/items/find_all?max_price=10")

      expect(response).to be_successful

      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body).to have_key(:data)
      expect(response_body[:data]).to be_an(Array)
      expect(response_body[:data].length).to eq(4)
      expect(response_body[:data][0][:attributes][:name]).to eq("c")
      expect(response_body[:data][1][:attributes][:name]).to eq("d")
      expect(response_body[:data][2][:attributes][:name]).to eq("e")
      expect(response_body[:data][3][:attributes][:name]).to eq("f")
    end

    it 'returns all items between prices in alph order' do
      item_1 = create(:item, unit_price: 3, name: "a")
      item_2 = create(:item, unit_price: 9, name: "b")
      item_3 = create(:item, unit_price: 4, name: "d")
      item_4 = create(:item, unit_price: 5, name: "e")
      item_5 = create(:item, unit_price: 6, name: "c")
      item_6 = create(:item, unit_price: 8, name: "f")

      get("/api/v1/items/find_all?min_price=4&max_price=8")

      expect(response).to be_successful

      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body).to have_key(:data)
      expect(response_body[:data]).to be_an(Array)
      expect(response_body[:data].length).to eq(4)
      expect(response_body[:data][0][:attributes][:name]).to eq("c")
      expect(response_body[:data][1][:attributes][:name]).to eq("d")
      expect(response_body[:data][2][:attributes][:name]).to eq("e")
      expect(response_body[:data][3][:attributes][:name]).to eq("f")
    end

    it 'returns all items with matching name in alphabetical order' do
      item_1 = create(:item, name: "jIob")
      item_2 = create(:item, name: "ajiO")
      item_3 = create(:item, name: "bJI9")
      item_4 = create(:item, name: "cJisd")
      item_5 = create(:item, name: "fjiok")
      item_6 = create(:item, name: "djiol")

      get("/api/v1/items/find_all?name=jio")

      expect(response).to be_successful

      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body).to have_key(:data)
      expect(response_body[:data]).to be_an(Array)
      expect(response_body[:data].length).to eq(4)
      expect(response_body[:data][0][:attributes][:name]).to eq("ajiO")
      expect(response_body[:data][1][:attributes][:name]).to eq("djiol")
      expect(response_body[:data][2][:attributes][:name]).to eq("fjiok")
      expect(response_body[:data][3][:attributes][:name]).to eq("jIob")
    end
  end

end