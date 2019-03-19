json.type @type
json.set! :item do
  json.set! :machine do
    json.mac @mac[:mac]
  end

  json.set! :data do
    json.array! @result do |result|
      json.date result.date
      json.beginning result.beginning
      json.set! :ads do
        json.array! result.ads, :channel, :value, :range
      end
    end
  end
end

