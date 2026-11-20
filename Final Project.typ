#set page(paper: "us-letter", margin: 1in)
#set text(font: "New Computer Modern", size: 11pt)
#set par(justify: true, leading: 0.65em)

#set heading(numbering: none)
#set figure(numbering: "1")
#set figure.caption(position: bottom)


// ---------- Specialized question format ----------
// Each question is rendered as a "Question block" with a colored
// header banner and a distinct, readable body.
#let question(
  number: none,
  body,
) = {
  block(
    width: 100%,
    fill: none,
    inset: 0pt,
    above: 1.2em,
    below: 0.6em,
  )[
    #grid(
      columns: (auto, 1fr),
      column-gutter: 8pt,
      row-gutter: 4pt,
      align(left)[
        #box(
          fill: rgb("#1f4e79"),
          inset: (x: 12pt, y: 6pt),
          radius: 4pt,
        )[
          #text(fill: white, weight: "bold", size: 11pt)[
            Question #number
          ]
        ]
      ],
      align(left)[
        #box(
          fill: rgb("#eaf1f8"),
          inset: (x: 12pt, y: 6pt),
          radius: 4pt,
        )[
          #text(size: 10pt)[
            #body
          ]
        ]
      ],
    )
  ]
}

// ---------- Code block with caption ----------
#let matcode(caption: none, body) = block(
  width: 100%,
  fill: rgb("#f4f4f4"),
  inset: (x: 12pt, y: 10pt),
  radius: 4pt,
  stroke: 0.5pt + rgb("#cccccc"),
)[
  #set text(font: "Noto Sans Mono", size: 9pt)
  #if caption != none [
    #text(weight: "bold", size: 8.5pt, fill: gray)[#caption]
    #v(4pt)
  ]
  #body
]

// ---------- Answer box ----------
#let answer(body) = block(
  width: 100%,
  fill: rgb("#fdf6e3"),
  inset: (x: 12pt, y: 10pt),
  radius: 4pt,
  stroke: 0.5pt + rgb("#e0c060"),
)[
  #text(weight: "bold", size: 10pt, fill: rgb("#8a6d1f"))[Answer]
  #v(4pt)
  #body
]

#align(center)[
  #v(125pt)
  #text(size: 100pt)[ENT401]
  
  #text(size: 40pt)[Smart Alarm Clock Group Project
]
  
  #text(size: 20pt)[Students: Brian Mack and David Tapley]
  
  #text(size: 20pt)[Instructor: Reza Abrisham Baf]
  
  #text(size: 15pt, fill: gray)[November 30, 2026]
]
#v(10pt)

#pagebreak()

= Abstract
This group project looks at an IMU sensor and how it can be used to disable an alarm clock. The alarm clock is powered by an ESP32 with a BMX160 IMU and a small piezo buzzer. The alarm clock connects to the internet to allow it to get the current time automatically and also connect to your phone so that the alarm time can be set. The IMU detects motion using Euclidean Normalization and a threshold value so that when movement goes beyond the threshold value it will trigger the alarm to turn off.


= Introduction
In this group project our team built an alarm clock that can be turned off by shaking or hitting it. This movement is detected by an IMU accelerometer.

= Methods and Materials

The materials that are required to build this project are a computer with MATLAB and Arduino IDE installed, jumper wires, breadboard, a BMX160 IMU, and the BMX160 Arduino driver found at #link("https://github.com/DFRobot/DFRobot_BMX160")[https://github.com/DFRobot/DFRobot_BMX160], ESP32, and an piezo Buzzer

= Procedures
The first thing to do when build this project is to take a breadboard and insert the ESP32. Next wires on the buzzer and connect one to ground and the other to GPIO pin 19. It does not matter which wire on the buzzer goes where. Third, take the BMX160, wire ground to ground and VCC to 3.3 volts on the ESP32. Take the I2C Clock and connect that to GPIO pin 22 on the ESP32. The I2C Data wire should be connected to GPIO pin 21 on the ESP32. Now that everything is wired open the `ArduinoProgram.ino` file and edit the wifi SSID and password to match your wifi network. Then upload the program to the ESP32. Once the program is uploaded check the console in Arduino IDE and find the IP address that is printed there. Use this IP address to navigate in the web browser to the website on the ESP32 and set the time that the alarm should go off. Finally, wait till the alarm goes off and then dismiss the alarm by shaking the alarm clock.

= Results
Results are from the IMU plotted in MATLAB:

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,

  figure(
    image("media/steady_state.png", height: 25%),
    caption: [Alarm Clock Stationary],
  ) ,

  figure(
    image("media/moving_around.png", height: 25%),
    caption: [Alarm Clock Moving Around],
  ),
)

#figure(
  image("media/shake.png", width: 90%),
  caption: [Alarm Clock Shake],
) <shake>

= Discussion

This project uses an IMU connected to an ESP32 to get IMU data and process it to detect any movement. In Figure 1, you can see all three axes of the IMU. In Figure 2, you can see how, as the IMU is rotated around, gravity affects each axis differently, making it hard to set a good threshold because it depends on the orientation. Now, if you look at the Euclidean Acceleration Magnitude in Figure 2, you can see that it stays pretty steady even as the IMU is moved around slowly and rotated. This is perfect for regulating the values and setting a good threshold. In Figure 3, it shows what it looks like if the IMU is shaken. The Euclidean normalization takes the values from all three axes and allows a threshold of 1.25 to be set, and if the value goes over this threshold, then the alarm can be dismissed.


= Conclusion

In conclusion, the smart alarm clock is a good example of how IMUs can be a very useful addition to a project. Here only the accelerometer data was used but IMUs also have gyro data and potentially magnetometers. Since IMU accelerometers tend to have a lot of complex and sometimes noise data euclidean normalization was used to process the data and convert it to one useful number that could be used to set a threshold on how much movement was required to dismiss the alarm.


= Appendices A
The following MATLAB code was used in this lab to generate the graph of the accelerometer and Euclidean Normalization.

#matcode(caption: "audio.m")[```matlab

clear;
clc;
close all;

s = serialport("COM6", 115200);
configureTerminator(s, "LF");
flush(s);

% Settings
windowSize = 10;

% Data storage
data = zeros(0, 3);
euclidean = zeros(0, 1);
time = zeros(0, 1);

tic;

% Create figure
figure('Name', 'BMX160 Live Acceleration', 'NumberTitle', 'off');

tiledlayout(2, 1);

% 1. X, Y, Z acceleration
ax1 = nexttile;
hAccel = plot(ax1, nan, nan, nan, nan, nan, nan);
title(ax1, "BMX160 Acceleration");
xlabel(ax1, "Time (seconds)");
ylabel(ax1, "Acceleration (g)");
legend(ax1, "X", "Y", "Z");
grid(ax1, "on");

% 2. Euclidean magnitude
ax2 = nexttile;
hEuclidean = plot(ax2, nan, nan);
title(ax2, "Euclidean Acceleration Magnitude");
xlabel(ax2, "Time (seconds)");
ylabel(ax2, "Acceleration (g)");
legend(ax2, "Euclidean Magnitude");
grid(ax2, "on");

while ishandle(ax1)

    line = readline(s);
    values = sscanf(line, 'a/g:%f%f%f');

    if numel(values) ~= 3
        continue;
    end

    % Extract acceleration and convert m/s^2 to g
    accel = values(1:3)' / 9.81;

    % Store measurements
    t = toc;

    data(end+1, :) = accel;
    time(end+1, 1) = t;

    % Euclidean magnitude in g
    magnitude = sqrt(sum(accel.^2));

    euclidean(end+1, 1) = magnitude;

    % Keep only recent samples
    while time(end) - time(1) > windowSize
        data(1,:) = [];
        euclidean(1) = [];
        time(1) = [];
    end

    % Update X, Y, Z plot
    for i = 1:3
        set(hAccel(i), ...
            'XData', time, ...
            'YData', data(:,i));
    end

    % Update Euclidean magnitude plot
    set(hEuclidean, ...
        'XData', time, ...
        'YData', euclidean);

    % Scroll time axes
    xLimits = [max(0,t-windowSize), max(windowSize,t)];

    xlim(ax1, xLimits);
    ylim(ax1, [-3 3]);
    xlim(ax2, xLimits);
    ylim(ax2, [-3 3]);


    drawnow limitrate;
end

clear s;
```]

The following Arduino code was used in this lab to serial print the accelerometer values to the console for MATLAB to graph.

#matcode(caption: "arduino.ino")[```cpp
#include <Wire.h>
#include <DFRobot_BMX160.h>

DFRobot_BMX160 bmx160;

sBmx160SensorData_t accel;
sBmx160SensorData_t gyro;

#define LED_PIN 13

bool blinkState = false;

void setup() {
    Wire.begin();
    Serial.begin(115200);

    Serial.println("Initializing I2C devices...");
    if (bmx160.begin() != true) {
        Serial.println("BMX160 initialization failed");
        while (1);
    }
    Serial.println("Testing device connections...");
    Serial.println("BMX160 connection successful");

    pinMode(LED_PIN, OUTPUT);
}

void loop() {
    bmx160.getAllData(NULL, NULL, &accel);


    float ax = accel.x ;
    float ay = accel.y ;
    float az = accel.z ;




    Serial.print("a/g:\t");
    Serial.print(ax); Serial.print("\t");
    Serial.print(ay); Serial.print("\t");
    Serial.print(az); Serial.println("\t");


    // Blink LED to indicate activity
    blinkState = !blinkState;
    digitalWrite(LED_PIN, blinkState);
}
```]

= Appendices B
The following code was used to run the alarm clock and webpage on the ESP32. To upload this to an ESP32 place both the `alarm_page.h` and `ArduinoProgram.ino` in a folder called `ArduinoProgram`.

#matcode(caption: "ArduinoProgram.ino")[```cpp
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

```]

#matcode(caption: "alarm_page.h")[```html
#ifndef ALARM_PAGE_H
#define ALARM_PAGE_H

const char ALARM_PAGE_HTML[] PROGMEM = R"rawliteral(
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ESP32 Daily Alarm</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 40px; background-color: #f5f5f5; }
    .container { max-width: 500px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
    h1 { color: #333; text-align: center; }
    .time-display { text-align: center; font-size: 24px; color: #666; margin-bottom: 20px; }
    .alarm-form { margin-top: 30px; }
    .form-group { margin-bottom: 20px; }
    label { display: block; margin-bottom: 5px; color: #333; font-weight: bold; }
    .time-inputs { display: flex; gap: 10px; align-items: center; }
    .time-inputs input { flex: 1; padding: 10px; font-size: 16px; border: 1px solid #ddd; border-radius: 5px; box-sizing: border-box; text-align: center; }
    .time-separator { font-size: 24px; font-weight: bold; }
    .checkbox-group { display: flex; align-items: center; gap: 10px; }
    input[type=checkbox] { width: 20px; height: 20px; }
    button { width: 100%; padding: 12px; background-color: #007bff; color: white; border: none; border-radius: 5px; font-size: 16px; cursor: pointer; }
    button:hover { background-color: #0056b3; }
    .status { text-align: center; margin-top: 20px; padding: 10px; background-color: #e9ecef; border-radius: 5px; }
  </style>
</head>
<body>
  <div class="container">
    <h1>Daily Alarm</h1>
    <div class="time-display">
      <div>%DATE%</div>
      <div><strong>%TIME%</strong></div>
    </div>
    <form class="alarm-form" action="/set" method="GET">
      <div class="form-group checkbox-group">
        <input type="checkbox" id="enabled" name="enabled" value="1" %ENABLED%>
        <label for="enabled" style="margin-bottom: 0;">Enable Daily Alarm</label>
      </div>
      <div class="form-group">
        <label>Alarm Time (Military Time - 24 Hour)</label>
        <div class="time-inputs">
          <input type="number" id="hour" name="hour" min="0" max="23" placeholder="HH" value="%HOUR%" required>
          <span class="time-separator">:</span>
          <input type="number" id="minute" name="minute" min="0" max="59" placeholder="MM" value="%MINUTE%" required>
        </div>
      </div>
      <button type="submit">Save Alarm</button>
    </form>
    <div class="status">
      <strong>Status:</strong> %STATUS%<br>
      %ALARM_INFO%
    </div>
    <div style="text-align: center; margin-top: 15px; color: #666; font-size: 12px;">
      ESP32 IP: %IP%
    </div>
  </div>
</body>
</html>
)rawliteral";

#endif
```]



