json.type @type
json.set! :item do
  json.set! :machine do
    json.mac @mac[:mac]
  end

  json.set! :data do
    json.array! @result, :black, :dry, :wet, :humidity, :wbgt_data, :date, :beginning
  end
end

