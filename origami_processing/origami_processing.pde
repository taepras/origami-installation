import ddf.minim.*;
import ddf.minim.signals.*;
import javax.sound.sampled.*;
import ddf.minim.ugens.*;

import processing.serial.*;       


// config
final boolean PARTY_MODE = false;
final int NUM_SPEAKERS = 3;
final int[] SPEAKER_CHANNELS = {3, 5, 6};
//final int[] SPEAKER_CHANNELS = {1, 2, 4};
final boolean ENABLE_SERIAL = true;
final boolean DEBUG = true;


Serial serial;
SpeakerSet[] speakers;

boolean lastTrigger;


void setup () {
  size(400, 600);
  
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
  
  //for (int i = 0; i < speakers.length; i++) {
  //  speakers[i] = new SpeakerSet(this, i, "whispering-sounds.mp3", mixerInfo, SPEAKER_CHANNELS[i], serial);
    
  //  //speakers[i].setQuestionFile("q1/q1.mp3");
  //  speakers[i].addAnswerFile("q1/answers/a1.mp3");
  //  speakers[i].addAnswerFile("q1/answers/a2.mp3");
  //  speakers[i].addAnswerFile("q1/answers/a3.mp3");
  //  speakers[i].start();
  //}
  
  speakers[0] = new SpeakerSet(this, 0, "whispering-sounds.mp3", mixerInfo, SPEAKER_CHANNELS[0], serial);
    
  //speakers[i].setQuestionFile("q1/q1.mp3");
  speakers[0].addAnswerFile("answers/q3_1.mp3");
  speakers[0].addAnswerFile("answers/q3_5.mp3");
  speakers[0].addAnswerFile("answers/q3_2.mp3");
  speakers[0].addAnswerFile("answers/q3_4.mp3");
  speakers[0].addAnswerFile("answers/q3_3.mp3");
  speakers[0].addAnswerFile("answers/q3_6.mp3");
  speakers[0].addAnswerFile("answers/q3_7.mp3");
  
  if (PARTY_MODE) {
    speakers[0].addAnswerFile("answers/lol_end1.mp3");
  }
  speakers[0].start();
  
  
  if (NUM_SPEAKERS > 1) {
    
    delay(3812);
    
    speakers[1] = new SpeakerSet(this, 1, "whispering-sounds.mp3", mixerInfo, SPEAKER_CHANNELS[1], serial);
      
    //speakers[i].setQuestionFile("q1/q1.mp3");
    speakers[1].addAnswerFile("answers/q2_3.mp3");
    speakers[1].addAnswerFile("answers/q2_1.mp3");
    speakers[1].addAnswerFile("answers/q2_7.mp3");
    speakers[1].addAnswerFile("answers/q2_5.mp3");
    speakers[1].addAnswerFile("answers/q2_2.mp3");
    speakers[1].addAnswerFile("answers/q2_6.mp3");
    speakers[1].addAnswerFile("answers/q2_4.mp3");
    
    
    if (PARTY_MODE) {
      speakers[1].addAnswerFile("answers/q2_extra1.mp3");
      speakers[1].addAnswerFile("answers/q2_extra2.mp3");
      speakers[1].addAnswerFile("answers/q2_extra3.mp3");
      speakers[1].addAnswerFile("answers/lol_end2.mp3");
    }
    speakers[1].start();
  }
  
  if (NUM_SPEAKERS > 2) {
    
    delay(5021);
    
    speakers[2] = new SpeakerSet(this, 2, "whispering-sounds.mp3", mixerInfo, SPEAKER_CHANNELS[2], serial);
      
    //speakers[i].setQuestionFile("q1/q1.mp3");
    speakers[0].addAnswerFile("answers/q1_1.mp3");
    speakers[2].addAnswerFile("answers/q1_7.mp3");
    speakers[2].addAnswerFile("answers/q1_4.mp3");
    speakers[2].addAnswerFile("answers/q1_6.mp3");
    speakers[2].addAnswerFile("answers/q1_5.mp3");
    speakers[2].addAnswerFile("answers/q1_2.mp3");
    speakers[2].addAnswerFile("answers/q1_3.mp3");
    
    if (PARTY_MODE) {
      speakers[2].addAnswerFile("answers/lol_end3.mp3");
    }
    speakers[2].start();
  }
  
  //speakers[0].setQuestionFile("q1/q1.mp3");
  //speakers[0].addAnswerFile("q1/answers/a1.mp3");
  //speakers[0].addAnswerFile("q1/answers/a2.mp3");
  //speakers[0].addAnswerFile("q1/answers/a3.mp3");
  //speakers[0].start();
}

void draw () {
  background(255);
  textSize(20);
  
  if (serial != null && serial.available() > 0) {
    String in = serial.readStringUntil('\n');
    
    if (in != null) {
      print("receiving: " + in);
      String[] inParts = in.split(",");
      if (inParts.length >= 4 && inParts[0].charAt(0) == 'p') {
        
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
