import ddf.minim.*;
import ddf.minim.signals.*;
import javax.sound.sampled.*;
import ddf.minim.ugens.*;

import processing.serial.*;       


// config
final int NUM_SPEAKERS = 1;
final int[] SPEAKER_CHANNELS = {1, 1, 1, 1};
final boolean ENABLE_SERIAL = true;
final boolean DEBUG = true;


Serial serial;
SpeakerSet[] speakers;

boolean lastTrigger;


void setup () {
  size(350, 200);
  
  serial = null;
  if (ENABLE_SERIAL) {
    printArray(Serial.list());
    serial = new Serial(this, Serial.list()[0], 115200);
  }
  
  Mixer.Info[] mixerInfo;
  mixerInfo = AudioSystem.getMixerInfo();
  for (int i = 0; i < mixerInfo.length; i++) {
    println(i + " = " + mixerInfo[i].getName());
  } 
  
  speakers = new SpeakerSet[NUM_SPEAKERS];
  
  for (int i = 0; i < speakers.length; i++) {
    speakers[i] = new SpeakerSet(this, i, "whispering-sounds.mp3", mixerInfo, SPEAKER_CHANNELS[i], serial);
    
    //speakers[i].setQuestionFile("q1/q1.mp3");
    speakers[i].addAnswerFile("q1/answers/a1.mp3");
    speakers[i].addAnswerFile("q1/answers/a2.mp3");
    speakers[i].addAnswerFile("q1/answers/a3.mp3");
    speakers[i].start();
  }
  
  delay(500);
  
  //speakers[0].setQuestionFile("q1/q1.mp3");
  //speakers[0].addAnswerFile("q1/answers/a1.mp3");
  //speakers[0].addAnswerFile("q1/answers/a2.mp3");
  //speakers[0].addAnswerFile("q1/answers/a3.mp3");
  //speakers[0].start();
}

void draw () {
  background(255);
  
  if (serial != null && serial.available() > 0) {
    String in = serial.readStringUntil('\n');
    print(in);
    if (in != null) {
      String[] inParts = in.split(",");
      if (inParts[0].charAt(0) == 'p') {
        int actionIndex = Integer.parseInt(inParts[1].trim()); 
        float distance = Float.parseFloat(inParts[2].trim());
        boolean currentTrigger = Integer.parseInt(inParts[3].trim()) > 0;
        
        speakers[actionIndex].setDistance(distance);
        speakers[actionIndex].setAnswerTrigger(currentTrigger);
      }
    }
  }
  
  boolean anyAnswering = false;
  for (int i = 0; i < speakers.length; i++) {
    anyAnswering = anyAnswering || speakers[i].getIsPlayingAnswer();
  }
  
  for (int i = 0; i < speakers.length; i++) {
    if (anyAnswering) {
      speakers[i].setMasterVolume(0.7);
    } else {
      speakers[i].setMasterVolume(1);
    }
    speakers[i].update();
    speakers[i].draw(0, height * i / speakers.length, width, height / speakers.length);
  }
}

void mouseDragged () {
  if (!DEBUG)
    return;
  
  for (int i = 0; i < speakers.length; i++) {
    int x0 = 0;
    int y0 = height * i / speakers.length;
    int w = width;
    int h = height / speakers.length;
    if (x0 <= mouseX && mouseX <= x0 + w && y0 <= mouseY && mouseY <= y0 + h) {
      speakers[i].setDistance(mouseX - x0);
    }
  }
}

void mouseClicked () {
  for (int i = 0; i < speakers.length; i++) {
    int x0 = 0;
    int y0 = height * i / speakers.length;
    int w = width;
    int h = height / speakers.length;
    if (x0 <= mouseX && mouseX <= x0 + w && y0 <= mouseY && mouseY <= y0 + h) {
      speakers[i].playNextAnswer();
    }
  }
}
