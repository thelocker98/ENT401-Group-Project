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
