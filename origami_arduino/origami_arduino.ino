#include <Wire.h>
#include "Adafruit_MPR121.h"

#include "OrigamiModule.h"

const int NUM_MODULES = 3;
OrigamiModule origamis[NUM_MODULES];

const int CAP_THRESH_TOUCH = 3;
const int CAP_THRESH_RELEASE = 3;

const int CAP_THRESH_MANUAL = 48;

const bool CALIBRATE = false;

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
  origamis[0].setup(0, 2, 37, 2, 4, 22, 10, 43);
  origamis[1].setup(1, 4, 44, 6, 8, 23, 10, 60);
  origamis[2].setup(2, 6, 50, 11, 13, 25, 10, 43);
//  for (int i = 0; i < NUM_MODULES; i++) {
//    origamis[i].setup();
//  }
  Serial.println("Done setting up origami modules!");
}



void loop() {
  // put your main code here, to run repeatedly:
//  boolean currTouched = cap.touched();
\  
  if (CALIBRATE) {
    Serial.print(CAP_THRESH_MANUAL);
    Serial.print("\t");
  }
  for (int i = 0; i < NUM_MODULES; i++) {
    uint16_t currTouched = cap.filteredData(origamis[i].getCapTouchPin());
    if (CALIBRATE) {
      Serial.print(currTouched);
      Serial.print("\t");
    }
    origamis[i].readAndEmit(currTouched);
  }
  if (CALIBRATE) {
    Serial.println();
  }

  if (Serial.available() > 0) {
    String in = Serial.readStringUntil('\n');
    int index = in.charAt(0) - '0';
    int lightOn = in.charAt(2) - '0';
    origamis[index].setLightOn(lightOn);
  }

  if (!CALIBRATE) {
    for (int i = 0; i < NUM_MODULES; i++) {
      origamis[i].printStatus();
    }
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
