#include "BluetoothSerial.h"

BluetoothSerial SerialBT;

// Variables for dummy angles
float yaw = 0;
float pitch = 0;
float roll = 0;

void setup() {
  Serial.begin(115200);

  if (!SerialBT.begin("ESP32_MPU")) {
    Serial.println("Bluetooth failed to start");
    while (1);
  } else {
    Serial.println("Bluetooth started, device name: ESP32_MPU");
  }
}

void loop() {
  // Increment dummy angles smoothly
  yaw += 1.0;
  pitch += 0.5;
  roll += 0.25;

  if (yaw >= 360) yaw = 0;
  if (pitch >= 360) pitch = 0;
  if (roll >= 360) roll = 0;

  // Transmit dummy orientation data
  SerialBT.print(yaw); SerialBT.print(",");
  SerialBT.print(pitch); SerialBT.print(",");
  SerialBT.println(roll);

  delay(50); // 20 Hz update rate
}