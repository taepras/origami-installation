public class SpeakerSet {
  float MIN_VOL = -30;
  float MAX_VOL = 0;
  float MIN_DIST = 30;
  float MAX_DIST = 100;
  float LIGHT_DIST = 70;
  float FRAMES_TO_CHANGE_LIGHT = 10;
  float FRAMES_TO_TRIGGER_ANSWER = 4;
    
  Minim minim;
  AudioOutput output;
  AudioPlayer backgroundSound;

  //AudioPlayer questionSound;
  ArrayList<AudioPlayer> answerSounds;
  PApplet context;
  
  Serial serial;
  
  float questionFadeInStart = 0.5;
  
  //float currentQuestionVolume = 0;
  //float targetQuestionVolume = 0;
  
  float currentBgVolume = 0;
  float targetBgVolume = 0;
  
  float masterVolume = 1;
  
  int currentAnswerIndex = -1;
  
  float maxVolumeStep = 0.005;
  int index = -1;
  
  int lightChangeCounter = 0;
  
  float distance = 0;
  boolean isLightOn = false;
  
  boolean isPlayingAnswer = false;
  boolean isTriggeringAnswer = false;
  
  int answerTriggerCounter = 0;
  
  public SpeakerSet (PApplet context, int index, String defaultFilename, Mixer.Info[] mixerInfo, int channel, Serial serial) {
    this.minim = new Minim(context);
    Mixer mixer = AudioSystem.getMixer(mixerInfo[channel]);
    this.minim.setOutputMixer(mixer);
    this.output = this.minim.getLineOut();
    this.backgroundSound = this.minim.loadFile(defaultFilename);
    
    this.answerSounds = new ArrayList<AudioPlayer>();
    this.index = index;
    this.serial = serial;
  }
  
  public void update () {
    //float actualTargetQuestionVolume = targetQuestionVolume;
    float actualTargetBgVolume = targetBgVolume * masterVolume * (isPlayingAnswer ? 0 : 1);
    
    if (isPlayingAnswer) {
      // done playing an answer
      if (!answerSounds.get(currentAnswerIndex).isPlaying()) {
        // if still holding trigger
        if (isTriggeringAnswer && answerTriggerCounter >= FRAMES_TO_TRIGGER_ANSWER) {
          delay(3000);
          isPlayingAnswer = false;
          playNextAnswer();
        } else {
          if (serial != null) {
            serial.write(this.index + ",0");
          }
          delay(4000);
          isPlayingAnswer = false;
        }
      }
      //actualTargetQuestionVolume = 0;
      actualTargetBgVolume = 0;
    } else {
      if (isTriggeringAnswer && answerTriggerCounter >= FRAMES_TO_TRIGGER_ANSWER) {
        playNextAnswer();
      }
    }
    
    //if (currentQuestionVolume < actualTargetQuestionVolume) {
    //  currentQuestionVolume = min(currentQuestionVolume + maxVolumeStep, actualTargetQuestionVolume);
    //} else if (currentQuestionVolume > actualTargetQuestionVolume) {
    //  currentQuestionVolume = max(currentQuestionVolume - maxVolumeStep, actualTargetQuestionVolume);
    //}
    
    if (currentBgVolume < actualTargetBgVolume) {
      currentBgVolume = min(currentBgVolume + maxVolumeStep, actualTargetBgVolume);
    } else if (currentBgVolume > actualTargetBgVolume) {
      currentBgVolume = max(currentBgVolume - maxVolumeStep, actualTargetBgVolume);
    }
    
    backgroundSound.setGain(map(currentBgVolume, 0, 1, MIN_VOL, MAX_VOL));
    //questionSound.setGain(map(currentQuestionVolume, this.questionFadeInStart, 1, MIN_VOL, MAX_VOL));
  }
  
  public void draw (int x0, int y0, int w, int h) {
    if (isPlayingAnswer)
      fill(0, 0, 255);
    else
      fill(0);
      
    stroke(255, 255, 255);
    rect(x0, y0, w, h);
    
    fill(255, 255, 255);
    text(isTriggeringAnswer ? "touched" : "", x0 + 10, y0 + 50);
    
    line(x0 + distance, y0, x0 + distance, y0 + h);
    text("User dist", x0 + distance, y0 + 50);
    
    stroke(0, 255, 0);
    fill(0, 255, 0);
    line(x0 + MAX_DIST, y0, x0 + MAX_DIST, y0 + h);
    text("Max dist", x0 + MAX_DIST, y0 + 80);
    
    stroke(255, 0, 0);
    fill(255, 0, 0);
    line(x0 + MIN_DIST, y0, x0 + MIN_DIST, y0 + h);
    text("Min dist", x0 + MIN_DIST, y0 + 110);
    
    stroke(255, 255, 0);
    fill(255, 255, 0);
    line(x0 + LIGHT_DIST, y0, x0 + LIGHT_DIST, y0 + h);
    text("Light on thresh", x0 + LIGHT_DIST, y0 + 140);
  }

  public void addAnswerFile (String filename) {
    answerSounds.add(this.minim.loadFile(filename));
  }

  //public void setQuestionFile (String filename) {
  //  questionSound = this.minim.loadFile(filename);
  //  setQuestionVolume(currentQuestionVolume);
  //}
  
  public void playNextAnswer () {
    if (isPlayingAnswer)
      return;
    
    currentAnswerIndex = (currentAnswerIndex + 1) % answerSounds.size();
    
    answerSounds.get(currentAnswerIndex).rewind();
    answerSounds.get(currentAnswerIndex).play();
    isPlayingAnswer = true;
    
    if (serial != null) {
      serial.write(this.index + ",1\n");
      isLightOn = true;
    }          
  }

  public void start () {
    backgroundSound.loop();
    //questionSound.loop();
  }

  public void setQuestionFadeInStartPoint (float thresh) {
    this.questionFadeInStart = thresh;
  }

  public void setMasterVolume (float volume) {
    this.masterVolume = volume;
  }
  
  public void setAnswerTrigger (boolean trigger) {
    if (isTriggeringAnswer == trigger) {
      answerTriggerCounter++;
    } else {
      answerTriggerCounter = 0;
    }
    isTriggeringAnswer = trigger;
    println("trigger: " + (isTriggeringAnswer ? "true" : "false") + " " + answerTriggerCounter);
  }

  public void setDistance (float distance) {
    
    this.distance = distance;
    
    float volFromDist = map(distance, MIN_DIST, MAX_DIST, 0, 1);
    volFromDist = constrain(volFromDist, 0, 1);
    setBgVolume(volFromDist);
    
    if (serial != null) {
      if (this.distance < LIGHT_DIST) {
        if (lightChangeCounter > 0) {
           lightChangeCounter =  0;
        }
        lightChangeCounter--;
        if (lightChangeCounter <= FRAMES_TO_CHANGE_LIGHT && !isLightOn) {
          serial.write(this.index + ",1\n");
          isLightOn = true;
        }
      } else {
        if (lightChangeCounter < 0) {
          lightChangeCounter =  0;
        }
        lightChangeCounter++;
        if (!isPlayingAnswer && lightChangeCounter >= FRAMES_TO_CHANGE_LIGHT && isLightOn) {
          serial.write(this.index + ",0\n");
          isLightOn = false;
        }
      }
      //println("light: " + lightChangeCounter);
    }
  }

  public void setBgVolume (float volume) {
    //this.targetQuestionVolume = 0; //constrain(map(volume, 0, 0.8, 0, 1), 0, 1); //volume;
    if (isPlayingAnswer)
      return;
      
    this.targetBgVolume = constrain(volume, 0, 1);
  }

  public void playQuestion () {
    backgroundSound.play();
  }
  
  public boolean getIsPlayingAnswer () {
    return isPlayingAnswer;
  }
}
