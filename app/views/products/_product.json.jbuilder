json.extract! product, :id, :menu_id, :title_id, :size, :priority, :price, :limit, :remain, :created_at, :updated_at
json.url product_url(product, format: :json)
