#include <Wire.h>
#include <DFRobot_BMX160.h>
#include <WiFi.h>
#include "time.h"
#include <WebServer.h>
#include <Preferences.h>
#include "alarm_page.h"

// -----------------------------------------------------------------------------
// Configuration
// -----------------------------------------------------------------------------
constexpr uint8_t PIN_BUZZER = 19;
constexpr uint8_t PIN_I2C_SDA = 21;
constexpr uint8_t PIN_I2C_SCL = 22;

constexpr char WIFI_SSID[] = "hotspot1";
constexpr char WIFI_PASSWORD[] = "hotspot1";

constexpr unsigned long WIFI_CONNECT_TIMEOUT_MS = 15000;
constexpr unsigned long TIME_SYNC_TIMEOUT_MS = 10000;
constexpr unsigned long SERIAL_BAUD_RATE = 115200;

const char *ntpServer = "pool.ntp.org";
// Columbus, Ohio is in Eastern Time (EST/EDT)
const char *timeZone = "EST5EDT,M3.2.0,M11.1.0";

// -----------------------------------------------------------------------------
// Globals
// -----------------------------------------------------------------------------
DFRobot_BMX160 bmx160;
sBmx160SensorData_t accel;

WebServer server(80);
Preferences preferences;

// Alarm settings
struct Alarm {
  bool enabled;
  int hour;    // 0-23
  int minute;  // 0-59
};

Alarm dailyAlarm = { false, 7, 0 };
bool alarmTriggeredToday = false;
int lastCheckedDay = -1;
bool triggering = false;


// -----------------------------------------------------------------------------
// Wi-Fi
// -----------------------------------------------------------------------------
bool connectToWiFi() {
  Serial.print("Connecting to ");
  Serial.println(WIFI_SSID);

  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  const unsigned long startTime = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - startTime < WIFI_CONNECT_TIMEOUT_MS) {
    delay(500);
    Serial.print(".");
  }
  Serial.println();

  if (WiFi.status() == WL_CONNECTED) {
    Serial.print("Wi-Fi connected. IP address: ");
    Serial.println(WiFi.localIP());
    return true;
  }

  Serial.println("Wi-Fi connection failed.");
  return false;
}

// -----------------------------------------------------------------------------
// Time
// -----------------------------------------------------------------------------
bool syncTime() {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("Cannot sync time: Wi-Fi not connected.");
    return false;
  }

  Serial.println("Syncing time from NTP...");
  configTzTime(timeZone, ntpServer);

  const unsigned long startTime = millis();
  struct tm timeinfo;
  while (!getLocalTime(&timeinfo) && millis() - startTime < TIME_SYNC_TIMEOUT_MS) {
    delay(250);
    Serial.print(".");
  }
  Serial.println();

  if (getLocalTime(&timeinfo)) {
    Serial.println("Time synchronized successfully.");
    Serial.println(&timeinfo, "Current time: %A, %B %d %Y %H:%M:%S");
    return true;
  }

  Serial.println("Failed to obtain time from NTP.");
  return false;
}

// -----------------------------------------------------------------------------
// Buzzer
// -----------------------------------------------------------------------------

void ringAlarm() {
  tone(PIN_BUZZER, 1000);
  delay(100);
  noTone(PIN_BUZZER);

  delay(100);

  tone(PIN_BUZZER, 1000);
  delay(100);
  noTone(PIN_BUZZER);

  delay(100);
}

// -----------------------------------------------------------------------------
// Preferences (Alarm Storage)
// -----------------------------------------------------------------------------
void loadAlarm() {
  preferences.begin("alarm", false);
  dailyAlarm.enabled = preferences.getBool("enabled", false);
  dailyAlarm.hour = preferences.getInt("hour", 7);
  dailyAlarm.minute = preferences.getInt("minute", 0);
  preferences.end();
  Serial.printf("Loaded alarm: %s %02d:%02d\n",
                dailyAlarm.enabled ? "ON" : "OFF",
                dailyAlarm.hour, dailyAlarm.minute);
}

void saveAlarm() {
  preferences.begin("alarm", false);
  preferences.putBool("enabled", dailyAlarm.enabled);
  preferences.putInt("hour", dailyAlarm.hour);
  preferences.putInt("minute", dailyAlarm.minute);
  preferences.end();
  Serial.println("Alarm saved to preferences.");
}

// -----------------------------------------------------------------------------
// Web Server
// -----------------------------------------------------------------------------
String getWebPage() {
  struct tm timeinfo;
  String currentTime = "--:--";
  String currentDate = "";

  if (getLocalTime(&timeinfo)) {
    char timeStr[9];
    char dateStr[40];
    strftime(timeStr, sizeof(timeStr), "%H:%M:%S", &timeinfo);
    strftime(dateStr, sizeof(dateStr), "%A, %B %d %Y", &timeinfo);
    currentTime = String(timeStr);
    currentDate = String(dateStr);
  }

  String html = FPSTR(ALARM_PAGE_HTML);

  // Replace placeholders
  html.replace("%DATE%", currentDate);
  html.replace("%TIME%", currentTime);
  html.replace("%ENABLED%", dailyAlarm.enabled ? "checked" : "");
  html.replace("%HOUR%", String(dailyAlarm.hour));
  html.replace("%MINUTE%", String(dailyAlarm.minute));

  html.replace("%STATUS%", dailyAlarm.enabled ? "Enabled" : "Disabled");

  String alarmInfo = "";
  if (dailyAlarm.enabled) {
    alarmInfo = "<strong>Alarm set for:</strong> " + String(dailyAlarm.hour < 10 ? "0" : "") + String(dailyAlarm.hour) + ":" + String(dailyAlarm.minute < 10 ? "0" : "") + String(dailyAlarm.minute);
  }
  html.replace("%ALARM_INFO%", alarmInfo);

  html.replace("%IP%", WiFi.localIP().toString());

  return html;
}

void handleRoot() {
  server.send(200, "text/html", getWebPage());
}

void handleSetAlarm() {
  if (server.hasArg("enabled")) {
    dailyAlarm.enabled = true;
  } else {
    dailyAlarm.enabled = false;
  }

  if (server.hasArg("hour")) {
    dailyAlarm.hour = server.arg("hour").toInt();
    // Clamp values
    if (dailyAlarm.hour < 0) dailyAlarm.hour = 0;
    if (dailyAlarm.hour > 23) dailyAlarm.hour = 23;
  }

  if (server.hasArg("minute")) {
    dailyAlarm.minute = server.arg("minute").toInt();
    // Clamp values
    if (dailyAlarm.minute < 0) dailyAlarm.minute = 0;
    if (dailyAlarm.minute > 59) dailyAlarm.minute = 59;
  }

  alarmTriggeredToday = false;  // Reset for today
  saveAlarm();

  server.sendHeader("Location", "/", true);
  server.send(302, "text/plain", "Redirecting...");
}

void handleNotFound() {
  server.send(404, "text/plain", "Page not found");
}

// -----------------------------------------------------------------------------
// Setup
// -----------------------------------------------------------------------------
void setup() {
  Serial.begin(SERIAL_BAUD_RATE);
  pinMode(PIN_BUZZER, OUTPUT);


  // ESP32 default I2C pins
  Wire.begin(PIN_I2C_SDA, PIN_I2C_SCL);

  if (!bmx160.begin()) {
    Serial.println("BMX160 initialization failed!");
    while (true) {
      delay(1000);
    }
  }
  Serial.println("BMX160 initialized successfully.");

  loadAlarm();

  if (connectToWiFi()) {
    syncTime();
  } else {
    Serial.println("Continuing without Wi-Fi/time sync.");
  }

  // Setup web server routes
  server.on("/", handleRoot);
  server.on("/set", handleSetAlarm);
  server.onNotFound(handleNotFound);
  server.begin();
  Serial.println("Web server started!");
  Serial.print("Open http://");
  Serial.print(WiFi.localIP());
  Serial.println(" in your browser");
}

// -----------------------------------------------------------------------------
// Main loop
// -----------------------------------------------------------------------------
void checkAlarm() {
  if (!dailyAlarm.enabled) {
    return;
  }
  if (WiFi.status() != WL_CONNECTED) {
    return;
  }

  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {
    return;
  }

  // Reset alarm trigger flag at start of new day
  if (lastCheckedDay != timeinfo.tm_mday) {
    alarmTriggeredToday = false;
    lastCheckedDay = timeinfo.tm_mday;
  }

  // Check if alarm should trigger (no seconds)
  if (!alarmTriggeredToday && timeinfo.tm_hour == dailyAlarm.hour && timeinfo.tm_min == dailyAlarm.minute) {
    alarmTriggeredToday = true;
    triggering = true;
  }
}

void loop() {
  server.handleClient();

  if (WiFi.status() != WL_CONNECTED) {
    connectToWiFi();
    if (WiFi.status() == WL_CONNECTED) {
      syncTime();
    }
  }
  checkAlarm();

  if (triggering)
    ringAlarm();

  bmx160.getAllData(nullptr, nullptr, &accel);

  float totalG = sqrt(accel.x * accel.x + accel.y * accel.y + accel.z * accel.z) / 9.81;

  if (totalG > 1.25) {
    Serial.println("Acceleration exceeds 1.25 G!");
    triggering = false;
  }

  delay(100);
}
