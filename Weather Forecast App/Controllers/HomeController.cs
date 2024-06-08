using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;
using Microsoft.Extensions.Logging;
using WeatherForecastApp_MVC.Models;

namespace WeatherForecastApp_MVC.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;

        public HomeController(ILogger<HomeController> logger)
        {
            _logger = logger;
        }

        public IActionResult Index()
        {
            return View();
        }

        public IActionResult WeatherPrivate()
        {
            return View();
        }

        [HttpGet]
        public JsonResult GetWeather(string cityName)
        {
            WeatherClass weath = new WeatherClass();
            var weatherData = weath.GetWeatherForecast(cityName);
            return Json(weatherData);
        }
        [HttpGet]
        public JsonResult GetForecast(string cityName)
        {
            FiveDaysForecast fivedays_forecast = new FiveDaysForecast();
            var forecast_data = fivedays_forecast.Get5daysForecast(cityName);
            return Json(forecast_data);
        }

        public IActionResult Privacy()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}
