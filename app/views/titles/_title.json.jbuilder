json.extract! title, :id, :name, :priority, :description, :image_url, :created_at, :updated_at
json.url title_url(title, format: :json)
