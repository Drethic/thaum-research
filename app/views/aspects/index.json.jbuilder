json.array!(@aspects) do |aspect|
  json.extract! aspect, :id
  json.url aspect_url(aspect, format: :json)
end
