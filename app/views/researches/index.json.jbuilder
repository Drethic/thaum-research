json.array!(@researches) do |research|
  json.extract! research, :id
  json.url research_url(research, format: :json)
end
