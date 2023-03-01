class WeatherService
  
  def self.call(latitude, longitude)
    conn = Faraday.new('https://api.openweathermap.org') do |f|
      f.request :json # encode req bodies as JSON and automatically set the Content-Type header
      f.request :retry # retry transient failures
      f.response :json # decode response bodies as JSON
    end    

    # send request
    response = conn.get('/data/2.5/weather', {
      appid: Rails.application.credentials.openweather_api_key,
      lat: latitude,
      lon: longitude,
      units: "metric"
    })

    # validate the response data structure
    body = response.body
    body or raise StandardError.new "OpenWeather response body failed"
    body["main"] or raise StandardError.new "OpenWeather main section is missing"
    body["main"]["temp"] or raise StandardError.new body
    body["main"]["temp_min"] or raise StandardError.new "OpenWeather temperature minimum is missing"
    body["main"]["temp_max"] or raise StandardError.new "OpenWeather temperature maximum is missing"
    body["weather"] or raise StandardError.new "OpenWeather weather section is missing"
    body["weather"].length > 0 or raise StandardError.new "OpenWeather weather section is empty"
    body["weather"][0]["description"] or raise StandardError.new "OpenWeather weather description is missing"

    # build weather data
    weather = OpenStruct.new
    weather.temperature = body["main"]["temp"]
    weather.temperature_min = body["main"]["temp_min"]
    weather.temperature_max = body["main"]["temp_max"]
    weather.humidity = body["main"]["humidity"]
    weather.pressure = body["main"]["pressure"]
    weather.description = body["weather"][0]["description"]
    weather
  end
    
end
