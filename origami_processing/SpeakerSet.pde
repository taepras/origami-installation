public class SpeakerSet {
  float MIN_VOL = -30;
  float MAX_VOL = 0;
  float MIN_DIST = 30;
  float MAX_DIST = 100;
  float LIGHT_DIST = 70;
  float FRAMES_TO_CHANGE_LIGHT = 10;
    
  Minim minim;
  AudioOutput output;
  AudioPlayer backgroundSound;

  AudioPlayer questionSound;
  ArrayList<AudioPlayer> answerSounds;
  PApplet context;
  
  Serial serial;
  
  float questionFadeInStart = 0.5;
  
  float currentQuestionVolume = 0;
  float targetQuestionVolume = 0;
  
  float currentBgVolume = 0;
  float targetBgVolume = 0;
  
  float masterVolume = 1;
  
  int currentAnswerIndex = -1;
  
  float maxVolumeStep = 0.005;
  int index = -1;
  
  int lightChangeCounter = 0;
  
  float distance = 0;
  boolean isLightOn = false;
  
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
    float actualTargetQuestionVolume = targetQuestionVolume;
    float actualTargetBgVolume = targetBgVolume * masterVolume;
    
    if (currentAnswerIndex >= 0) {
      // done playing an answer
      if (!answerSounds.get(currentAnswerIndex).isPlaying()) {
        if (serial != null) {
          serial.write(this.index + ",0");
        }
        delay(5000);
        currentAnswerIndex = -1;
      }
      actualTargetQuestionVolume = 0;
      actualTargetBgVolume = 0;
    }
    
    if (currentQuestionVolume < actualTargetQuestionVolume) {
      currentQuestionVolume = min(currentQuestionVolume + maxVolumeStep, actualTargetQuestionVolume);
    } else if (currentQuestionVolume > actualTargetQuestionVolume) {
      currentQuestionVolume = max(currentQuestionVolume - maxVolumeStep, actualTargetQuestionVolume);
    }
    
    if (currentBgVolume < actualTargetBgVolume) {
      currentBgVolume = min(currentBgVolume + maxVolumeStep, actualTargetBgVolume);
    } else if (currentBgVolume > actualTargetBgVolume) {
      currentBgVolume = max(currentBgVolume - maxVolumeStep, actualTargetBgVolume);
    }
    
    //backgroundSound.setGain(map(currentBgVolume, this.questionFadeInStart, 1, MIN_VOL, MAX_VOL));
    //questionSound.setGain(map(currentQuestionVolume, this.questionFadeInStart, 1, MIN_VOL, MAX_VOL));
    backgroundSound.setGain(map(currentBgVolume, 0, 1, MIN_VOL, MAX_VOL));
    questionSound.setGain(map(currentQuestionVolume, this.questionFadeInStart, 1, MIN_VOL, MAX_VOL));
  }
  
  public void draw (int x0, int y0, int w, int h) {
    if (currentAnswerIndex >= 0)
      fill(0, 0, 255);
    else
      fill(0);
    stroke(255, 255, 255);
    rect(x0, y0, w, h);
    //line(x0 + currentQuestionVolume * w, y0, x0 + currentQuestionVolume * w, y0 + h);
    line(x0 + distance, y0, x0 + distance, y0 + h);
    
    stroke(255, 0, 0);
    //line(x0 + questionFadeInStart * w, y0, x0 + questionFadeInStart * w, y0 + h);
    stroke(0, 255, 0);
    line(x0 + MAX_DIST, y0, x0 + MAX_DIST, y0 + h);
    stroke(255, 0, 0);
    line(x0 + MIN_DIST, y0, x0 + MIN_DIST, y0 + h);
    stroke(255, 255, 0);
    line(x0 + LIGHT_DIST, y0, x0 + LIGHT_DIST, y0 + h);
    //line(x0 + questionFadeInStart * w, y0, x0 + questionFadeInStart * w, y0 + h);
  }

  public void addAnswerFile (String filename) {
    answerSounds.add(this.minim.loadFile(filename));
  }

  public void setQuestionFile (String filename) {
    questionSound = this.minim.loadFile(filename);
    setQuestionVolume(currentQuestionVolume);
  }
  
  public void playRandomAnswer () {
    if (isPlayingAnswer())
      return;
    
    currentAnswerIndex = (int)random(0, answerSounds.size());
    
    answerSounds.get(currentAnswerIndex).rewind();
    answerSounds.get(currentAnswerIndex).play();
  }

  public void start () {
    backgroundSound.loop();
    questionSound.loop();
  }
  
  public boolean isPlayingAnswer () {
    return currentAnswerIndex >= 0;
  }

  public void setQuestionFadeInStartPoint (float thresh) {
    this.questionFadeInStart = thresh;
  }

  public void setMasterVolume (float volume) {
    this.masterVolume = volume;
  }

  public void setDistance (float distance) {
    
    this.distance = distance;
    
    float volFromDist = map(distance, MAX_DIST, MIN_DIST, 0, 1);
    volFromDist = constrain(volFromDist, 0, 1);
    setQuestionVolume(volFromDist);
    
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
        if (lightChangeCounter >= FRAMES_TO_CHANGE_LIGHT && isLightOn) {
          serial.write(this.index + ",0\n");
          isLightOn = false;
        }
      }
      println("light: " + lightChangeCounter);
    }
  }

  public void setQuestionVolume (float volume) {
    this.targetQuestionVolume = 0; //constrain(map(volume, 0, 0.8, 0, 1), 0, 1); //volume;
    this.targetBgVolume = constrain(1 - volume, 0, 1);
  }

  public void playQuestion () {
    backgroundSound.play();
  }
}
