#include <Wiichuck.h>
#include <Wire.h>

Wiichuck wii;

void setup() {
  Serial.begin(9600);
  wii.init();
  wii.calibrate();  // calibration
}

void loop() {
  if (wii.poll()) {
    Serial.print(wii.joyX());
    Serial.print(", ");
    Serial.print(wii.joyY());
    Serial.print(", ");
    Serial.print(wii.accelX());
    Serial.print(", ");
    Serial.print(wii.accelY());
    Serial.print(", ");
    Serial.println(wii.accelZ());
//    Serial.print(", ");
//    Serial.print(wii.buttonC());
//    Serial.print(", ");
//    Serial.print(wii.buttonZ());
  }
  
  delay(20);
}
