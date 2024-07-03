#include <WiFi.h>
#include <DHT.h>
#include <FirebaseESP32.h> // Include the Firebase ESP32 library

#define DHTPIN 14  // Pin where the DHT11 is connected
#define DHTTYPE DHT11  // DHT 11

const int trigPin = 23; // Ultrasonic sensor trig pin
const int echoPin = 22; // Ultrasonic sensor echo pin
const int fanPin = 2; // Pin to control the fan
const int lightPin = 4; // Pin to control the light
const int waterPin = 5; // Pin to control water filling

DHT dht(DHTPIN, DHTTYPE);

const char* ssid = "your-ssid";
const char* password = "your-password";

const char* host = "your-firebase-project-id.firebaseio.com"; // Firebase project ID
const char* apiKey = "your-api-key"; // Firebase API Key

WiFiServer server(80);
FirebaseData firebaseData;

void setup() {
  Serial.begin(115200);
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  pinMode(fanPin, OUTPUT);
  pinMode(lightPin, OUTPUT);
  pinMode(waterPin, OUTPUT);

  dht.begin();

  // Connect to Wi-Fi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }

  // Start the server
  server.begin();

  // Initialize Firebase
  Firebase.begin(host, apiKey);
}

void loop() {
  // Check for a client connection
  WiFiClient client = server.available();
  if (client) {
    while (client.connected()) {
      if (client.available()) {
        String request = client.readStringUntil('\n');
        Serial.println(request);

        // Handle fan control
        if (request.indexOf("FAN_TOGGLE") >= 0) {
          digitalWrite(fanPin, !digitalRead(fanPin));
        }
        // Handle light control
        else if (request.indexOf("LIGHT_TOGGLE") >= 0) {
          digitalWrite(lightPin, !digitalRead(lightPin));
        }
        // Handle water tank filling
        else if (request.indexOf("FILL_WATER") >= 0) {
          digitalWrite(waterPin, HIGH);
          delay(5000); // Fill for 5 seconds
          digitalWrite(waterPin, LOW);
        }
      }

      // Read sensor data
      float temperature = dht.readTemperature();
      float humidity = dht.readHumidity();
      float waterLevel = getWaterLevel();

      // Upload data to Firebase
      uploadData(temperature, humidity, waterLevel);

      // Send sensor data to the client
      String data = String(temperature) + "," + String(humidity) + "," + String(waterLevel) + "\n";
      client.print(data);

      delay(5000); // Upload data every 5 seconds
    }
    client.stop();
  }
}

float getWaterLevel() {
  // Function to get water level using ultrasonic sensor
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  float duration = pulseIn(echoPin, HIGH);
  // Calculate distance in centimeters
  float distance = duration * 0.034 / 2;
  return distance;
}

void uploadData(float temperature, float humidity, float waterLevel) {
  // Upload data to Firebase
  Firebase.setInt(firebaseData, "/temperature", temperature);
  Firebase.setInt(firebaseData, "/humidity", humidity);
  Firebase.setInt(firebaseData, "/waterLevel", waterLevel);

  if (Firebase.failed()) {
    Serial.println("Failed to store data on Firebase");
    return;
  }

  Serial.println("Data uploaded to Firebase");
