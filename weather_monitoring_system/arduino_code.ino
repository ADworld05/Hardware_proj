#include <Wire.h>
#include <Adafruit_BMP085.h>
#include <DHT.h>

#define DHTPIN 2
#define DHTTYPE DHT11

#define MQ135 A0
#define RAIN_SENSOR A1

DHT dht(DHTPIN, DHTTYPE);
Adafruit_BMP085 bmp;

void setup() {

  Serial.begin(9600);
  dht.begin();

  if (!bmp.begin()) {
    Serial.println("BMP180 not found!");
    while (1);
  }

  Serial.println("Weather Monitoring System Started");
}

void loop() {

  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();

  float pressure = bmp.readPressure() / 100.0;
  float altitude = bmp.readAltitude();

  int airQuality = analogRead(MQ135);
  int rainValue = analogRead(RAIN_SENSOR);

  Serial.println("------ Weather Data ------");

  Serial.print("Temperature: ");
  Serial.print(temperature);
  Serial.println(" C");

  Serial.print("Humidity: ");
  Serial.print(humidity);
  Serial.println(" %");

  Serial.print("Pressure: ");
  Serial.print(pressure);
  Serial.println(" hPa");

  Serial.print("Altitude: ");
  Serial.print(altitude);
  Serial.println(" m");

  Serial.print("Air Quality: ");
  Serial.println(airQuality);

  Serial.print("Rain Sensor: ");
  Serial.println(rainValue);

  if (rainValue < 400) {
    Serial.println("Rain Detected!");
  }

  Serial.println("---------------------------");

  delay(2000);
}