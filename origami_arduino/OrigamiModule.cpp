#include "OrigamiModule.h"


void OrigamiModule::setup(int index, int pinTouchMpr121, int pinUltrasonicTrig, int pinUltrasonicEcho1, int pinUltrasonicEcho2, int pinRelay, int pinDistOut) {
  _index = index;
  _pinTouchMpr121 = pinTouchMpr121;
  _pinUltrasonicTrig = pinUltrasonicTrig;
  _pinUltrasonicEcho1 = pinUltrasonicEcho1;
  _pinUltrasonicEcho2 = pinUltrasonicEcho2;
  _pinRelay = pinRelay;
  _pinDistOut = pinDistOut;
  
  // set up relay
  pinMode(_pinRelay, OUTPUT);

  // set up ultrasonic input
   pinMode(_pinUltrasonicTrig, OUTPUT);
   pinMode(_pinUltrasonicEcho1, INPUT);
   pinMode(_pinUltrasonicEcho2, INPUT);
   pinMode(6, INPUT);
   pinMode(_pinDistOut, OUTPUT);

   digitalWrite(_pinRelay, LOW);
   delay(300);
   digitalWrite(_pinRelay, HIGH);
   delay(300);
   digitalWrite(_pinRelay, LOW);
}

void OrigamiModule::readAndEmit(uint16_t capReading) {
  _currTouched = capReading & 1 << _pinTouchMpr121;
  
  float d1 = readUltrasonic(_pinUltrasonicTrig, _pinUltrasonicEcho1);
  float d2 = readUltrasonic(_pinUltrasonicTrig, _pinUltrasonicEcho2);

  bool readError = d1 <= 0 && d2 <= 0;

  if (!readError) {
    _currDist = d1 <= 0 ? d2 : d2 <= 0 ? d1 : min(d1, d2);
    _currDistSmoothed = _sCoeff * _currDistSmoothed + (1 - _sCoeff) * _currDist;
    if (_currDist < DIST_TRIGGER_THRESHOLD) {
      _ultraSonicTriggerCounter = min(_ultraSonicTriggerCounter + 1, ULTRASONIC_COUNT_TRIG);
    } else {
      _ultraSonicTriggerCounter = max(_ultraSonicTriggerCounter - 1, -ULTRASONIC_COUNT_TRIG);
    }
  }
//  else {
//    _ultraSonicTriggerCounter = 0;
//    _ultraSonicReleaseCounter = 0;
//  }

  float ledLevel = map(_currDistSmoothed, DIST_MIN, DIST_MIN + (DIST_MAX - DIST_MIN) / 2, 255, 0);
  ledLevel = constrain(ledLevel, 0, 255);
  analogWrite(_pinDistOut, ledLevel);
  
  Serial.print("p,");
  Serial.print(_index);
  Serial.print(",");
  Serial.print(_currDistSmoothed);
//  Serial.print(constrain(1.0 - (float)(_currDistSmoothed - DIST_MIN) / (DIST_MAX - DIST_MIN), 0, 1));
  Serial.print(",");
  Serial.print(_currTouched);
//  Serial.print(",");
//  Serial.print(constrain(1.0 - (float)(d1 - DIST_MIN) / (DIST_MAX - DIST_MIN), 0, 1));
//  Serial.print(",");
//  Serial.print(constrain(1.0 - (float)(d2 - DIST_MIN) / (DIST_MAX - DIST_MIN), 0, 1));
//  Serial.print(",");
//  Serial.print(_currDistSmoothed);
//  Serial.print(",");
//  Serial.print(ledLevel);
//  Serial.print(",");
//  Serial.print((float)_ultraSonicTriggerCounter / ULTRASONIC_COUNT_TRIG);
  Serial.println();

  _lastTouched = _currTouched;
  _lastDist = _currDist;
}

void OrigamiModule::setLightOn (bool lightOn) {
  digitalWrite(_pinRelay, lightOn);
}

float OrigamiModule::readUltrasonic (int pinTrig, int pinEcho) {
  int t = millis();
  
  if (pinEcho == pinTrig) {
    pinMode(pinTrig, OUTPUT);  
  }
  // Clears the trigPin
  digitalWrite(pinTrig, LOW);
  delayMicroseconds(2);
  // Sets the trigPin on HIGH state for 10 micro seconds
  digitalWrite(pinTrig, HIGH);
  delayMicroseconds(10);
  digitalWrite(pinTrig, LOW);
  
  // Reads the echoPin, returns the sound wave travel time in microseconds
  if (pinEcho == pinTrig) {
    pinMode(pinEcho, INPUT);  
  }
  int duration = pulseIn(pinEcho, HIGH, 100000);
  float distance = duration * 0.034 / 2;
  
//  while (millis() - t < 20);
//  Serial.println(distance);
  return distance; 
}
