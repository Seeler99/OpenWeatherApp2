# OpenWeatherApp

OpenWeatherApp built by Albert Castro


The App fetches the current weather from openWeatherMap API and displays it on the main view. It gets the coordinates from the user current location and lets you find by city name as well.

Below the current weather info there's a collection View displaying the data for the upcoming weather. You can scroll horizontally in order to see the different days.

 
Notes:

- Unit test added to check we can fetch data from the server and error test scenario in case the city is not found.

- In order to get the current location to vancouver in the simulator, I added a GPX file. You can configure the app to use this or simply the default from SF. In the device it should use the actual device location. 
