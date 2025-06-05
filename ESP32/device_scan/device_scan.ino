#include <Wire.h>

void setup() {
  Wire.begin(21, 22); // Change to your SDA/SCL pins
  Serial.begin(115200);
  Serial.println("\nI2C Scanner");
}

void loop() {
  byte error, address;
  int nDevices = 0;

  for(address = 1; address < 127; address++ ) {
    Wire.beginTransmission(address);
    error = Wire.endTransmission();

    if (error == 0) {
      Serial.print("I2C device found at address 0x");
      if (address < 16) Serial.print("0");
      Serial.print(address, HEX);
      Serial.println("  ✓");

      nDevices++;
    }
  }

  if (nDevices == 0)
    Serial.println("No I2C devices found");

  delay(2000);
}
