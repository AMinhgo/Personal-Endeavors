using System;
using System.Net;
using System.Text.Json;

namespace WeatherForecastApp_MVC.Models
{
    public class WeatherClass
    {
        public object GetWeatherForecast(string cityName)
        {
            string api_key = "your_api_key";
            string encodedCityName = WebUtility.UrlEncode(cityName);
            string url = $"http://api.openweathermap.org/data/2.5/weather?q={encodedCityName}&APPID={api_key}&units=metric";

            using (var client = new WebClient())
            {
                try
                {
                    var content = client.DownloadString(url);
                    var jsonContent = JsonSerializer.Deserialize<object>(content);
                    return jsonContent;
                }
                catch (WebException webEx)
                {
                    // Handle web exceptions such as network issues
                    Console.WriteLine($"WebException occurred: {webEx.Message}");
                }
                catch (JsonException jsonEx)
                {
                    // Handle JSON parsing exceptions
                    Console.WriteLine($"JsonException occurred: {jsonEx.Message}");
                }
                catch (Exception ex)
                {
                    // Handle any other exceptions
                    Console.WriteLine($"An unexpected error occurred: {ex.Message}");
                }
            }

            return null;
        }
    }
}
