using Xunit;
using Moq;
using VisionIntelligenceWebApi.Controllers;
using VisionIntelligenceWebApi.Services;

public class WeatherApiTests
{
    [Fact]
    public void GetWeatherForecast_ReturnsExpectedResult()
    {
        // Arrange
        var mockService = new Mock<IWeatherService>();
        mockService.Setup(service => service.GetForecast()).Returns(new List<WeatherForecast>
        {
            new WeatherForecast { Date = DateTime.Now, TemperatureC = 25, Summary = "Sunny" }
        });

        var controller = new WeatherForecastController(mockService.Object);

        // Act
        var result = controller.Get();

        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result);
        var forecasts = Assert.IsType<List<WeatherForecast>>(okResult.Value);
        Assert.Single(forecasts);
        Assert.Equal(25, forecasts[0].TemperatureC);
        Assert.Equal("Sunny", forecasts[0].Summary);
    }
}
