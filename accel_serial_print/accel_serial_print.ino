
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
