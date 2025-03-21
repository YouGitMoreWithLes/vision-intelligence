import React, { useState, useEffect } from "react";
import FormField from "../Molecules/FormField";

const Form = () => {
  const [forecasts, setForecasts] = useState([]);

  const fetchForecasts = async () => {
    const response = await fetch("http://localhost:8080/WeatherForecast");
    const data = await response.json();
    setForecasts(data);
  };

  useEffect(() => {
    fetchForecasts();
  }, []);

  const handleSubmit = async (event) => {
    event.preventDefault();
    await fetchForecasts();
  };

  return (
    <div>
      <p>Welcome to the weather forecast!</p>
      <form onSubmit={handleSubmit}></form>
      {forecasts.length > 0 && (
        <table>
          <thead>
            <tr>
              <th>Date</th>
              <th>Temperature (C)</th>
              <th>Summary</th>
            </tr>
          </thead>
          <tbody>
            {forecasts.map((forecast, index) => (
              <tr key={index}>
                <td>{new Date(forecast.date).toLocaleDateString()}</td>
                <td>{forecast.temperatureC}</td>
                <td>{forecast.summary}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
};

export default Form;
