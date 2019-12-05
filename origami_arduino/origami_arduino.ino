#include <Wire.h>
#include "Adafruit_MPR121.h"

#include "OrigamiModule.h"

const int NUM_MODULES = 1;
OrigamiModule origamis[NUM_MODULES];

const int CAP_THRESH_TOUCH = 8;
const int CAP_THRESH_RELEASE = 4;

// You can have up to 4 on one i2c bus but one is enough for testing!
Adafruit_MPR121 cap = Adafruit_MPR121();



void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  while (!Serial) { delay(10); }

  // set up MPR121
  // Default address is 0x5A, if tied to 3.3V its 0x5B
  // If tied to SDA its 0x5C and if SCL then 0x5D
  if (!cap.begin(0x5A)) {
    Serial.println("MPR121 not found, check wiring?");
    while (1);
  }
  Serial.println("MPR121 found!");
  cap.setThresholds(CAP_THRESH_TOUCH, CAP_THRESH_RELEASE);

  // set up origami modules
  Serial.println("Setting up origami modules");
  origamis[0].setup(0, 2, 3, 4, 6, 5, 10);
//  for (int i = 0; i < NUM_MODULES; i++) {
//    origamis[i].setup();
//  }
  Serial.println("Done setting up origami modules!");
}



void loop() {
  // put your main code here, to run repeatedly:
  uint16_t currtouched = cap.touched();
  
  for (int i = 0; i < NUM_MODULES; i++) {
    origamis[i].readAndEmit(currtouched);
  }

  if (Serial.available() > 0) {
    String in = Serial.readStringUntil('\n');
    int index = in.charAt(0) - '0';
    int lightOn = in.charAt(2) - '0';
    origamis[index].setLightOn(lightOn);
  }

//  // debugging info
//  for (uint8_t i=0; i<12; i++) {
//    Serial.print(i); Serial.print("\t");
//    Serial.print(cap.filteredData(i)); Serial.print("\t");
//    Serial.print(cap.baselineData(i)); Serial.print("\t");
//    Serial.print(currtouched & 1 << i); Serial.print("\t");
//    Serial.println();
//  }
//  // put a delay so it isn't overwhelming
  delay(20);
}
