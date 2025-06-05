#include <Wire.h>
#include <MPU6050_light.h>
#include "BluetoothSerial.h"

// I2C pins
#define SDA_PIN 21
#define SCL_PIN 22

MPU6050 mpu(Wire);
BluetoothSerial SerialBT;
 
void setup() {
  Serial.begin(115200);
  Wire.begin(SDA_PIN, SCL_PIN);

  // Initialize MPU6050
  byte status = mpu.begin();
  if (status != 0) {
    Serial.println("MPU6050 initialization failed!");
    while (1);
  }
  Serial.println("MPU6050 initialized");

  delay(1000);
  mpu.calcOffsets();  // Auto-calibrate

  // Initialize Bluetooth
  if (!SerialBT.begin("ESP32_MPU")) {
    Serial.println("Bluetooth init failed");
    while (1);
  }
  Serial.println("Bluetooth started. Device name: ESP32_MPU");
}

void loop() {
  mpu.update();

  // Get angles
  float yaw = mpu.getAngleZ();   // Z-axis
  float pitch = mpu.getAngleX(); // X-axis
  float roll = mpu.getAngleY();  // Y-axis

  // Send as CSV to MATLAB
  SerialBT.print(yaw); SerialBT.print(",");
  SerialBT.print(pitch); SerialBT.print(",");
  SerialBT.println(roll);

  delay(50); // 20 Hz update rate
}