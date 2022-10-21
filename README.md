# Rails Engine API Project

## About

This project is Ruby on Rails API that exposes mock ecommerce data from a PostgeSQL database.
The API is deployed on heroku with the base url https://rails-engine-tm.herokuapp.com/api/v1
See below for availalble endpoints.

## Learning Goals

- Practice Exposing an API
- Format JSON responses using serializers
- Ensure compliance with JSON:API specifications
- Use RSpec to test API endpoints
- Utilize ActiveRecord to manage data

## Local Setup

    #clone the repository
    git clone git@github.com:musselmanth/rails-engine.git

    #navigate into directory
    cd rails-engine

    #install dependencies
    bundle install

    #setup database
    rails db:{create:migrate:seed}

## Availble Endpoints

Base URL: https://rails-engine-tm.herokuapp.com/api/v1

---

`get /merchants`

Returns a list of all merchants in the db. Default is 20 per page. Page and number per page can be specified with optional parameters `page` and `per_page`. Example:
`/merchants?per_page=50&page=2`

---

`get /merchants/#{id}/items`

Returns a list of all items belonging to a particular merchant with the provided id.

---

`get /items`

Returns a list of all items in the db. Default is 20 per page. Page and number per page can be specified with optional parameters `page` and `per_page`. Example:
`/items?per_page=50&page=2`

---

`get /items/#{id}/merchant`

Returns information about the merchant for a particular item with the provided id.

---

`get /items/#{id}`

Returns a single item with the provided id. Sample response:

    {
      "data": {
        "id": "6",
        "type": "item",
        "attributes": {
          "name": "Item Provident At",
          "description": "Numquam officiis reprehenderit.",
          "unit_price": 159.25,
          "merchant_id": 1
        }
      }
    }

---

`get /merchants/#{id}`

Returns a single merchant with provided id. Sample response:

    {
      "data": {
        "id": "6",
        "type": "merchant",
        "attributes": {
          "name": "Williamson Group"
        }
      }
    }

---

`post /items`

Creates a new item with the provided parameters. Parameters provided in raw JSON could look like:

    {
      "name": "value1",
      "description": "value2",
      "unit_price": 100.99,
      "merchant_id": 14
    }

---

`patch /items/#{id}`

Updates an existing item. Any or all attributes can be provided as parameters. For example:

    {
      "description": "value2",
      "unit_price": 100.99,
    }

---

`delete /itmes/#{id}`

Deletes an item from the database.

---

`get /items/find?name=#{search_query}`
`get /items/find?min_price=#{minimum_price}`
`get /items/find?max_price=#{maximum_price}`

Searches for a singe item that matches the provided param query. If multiple items are found the first alphabetically is returned. `min_price` and `max_price` can both be provided in order to search within a range.

---

`get /items/find_all?name=#{search_query}`
`get /items/find_all?min_price=#{minimum_price}`
`get /items/find_all?max_price=#{maximum_price}`

Searches for all items that match the provided param query. `min_price` and `max_price` can both be provided in order to search within a range.

---

`get /merchants/find?name=#{search_query}`
`get /merchants/find_all?name=#{search_query}`

Searches for either one or all merchants whose name match the provided search query

---

## Database Schema
