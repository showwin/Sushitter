json.array!(@dictionaries) do |dictionary|
  json.extract! dictionary, :id, :owner, :word, :value
  json.url dictionary_url(dictionary, format: :json)
end
