#ifndef ORIGAMI_MODULE
#define ORIGAMI_MODULE

#include <Arduino.h>

class OrigamiModule {
public:
  OrigamiModule () {};
  void setup(int index, int pinTouchMpr121 = 2, int pinUltrasonicTrig = 3, int pinUltrasonicEcho = 4, int pinUltrasonicEcho2 = 6, int pinRelay = 5, int _pinDistOut = 10, int capThresh = 45);
  void readAndEmit(bool isTouching);
  void readAndEmit(uint16_t capReading);

  int getCapTouchPin() { return _pinTouchMpr121; };

  void printStatus();
  void setLightOn(bool on);
  
//  void printDebug();
//  bool isTouched();
//  int getDist();
  
protected:
  float readUltrasonic(int pinTrig, int pinEcho);

  int _pinRelay = 5;
  int _pinTouchMpr121 = 2;
  int _pinUltrasonicTrig = 3;
  int _pinUltrasonicEcho1 = 4;
  int _pinUltrasonicEcho2 = 6;
  int _pinDistOut = 6;
  
  int DIST_MIN = 30;
  int DIST_MAX = 250;
  float DIST_TRIGGER_THRESHOLD = 100;
  float DIST_RELEASE_THRESHOLD = 150;
  int ULTRASONIC_COUNT_TRIG = 3;

  bool _lastTouched = false;
  bool _currTouched = false;

  float _lastDistTriggered = false;
  float _currDistTriggered = false;
  float _lastDist = 0;
  float _currDist = 0;

  int _index = 0;

  int _ultraSonicTriggerCounter = 0;
  int _ultraSonicReleaseCounter = 0;

  float _currDistSmoothed = 0;
  float _sCoeff = 0.7;

  int _capThresh;
};

#endif //ORIGAMI_MODULE
