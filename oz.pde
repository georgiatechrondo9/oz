import controlP5.*;
import beads.*;
import org.jaudiolibs.beads.*;
import java.util.*;
import guru.ttslib.*;

//declare global variables at the top of your sketch
//AudioContext ac; is declared in helper_functions

ControlP5 p5;
TTS tts;

SamplePlayer frying;
SamplePlayer oven;
SamplePlayer cutting;
SamplePlayer player;
SamplePlayer salt;
SamplePlayer pepper;
SamplePlayer contamination;
SamplePlayer downTime;
SamplePlayer timerSound;


RadioButton micEnable;
UGen mic;
boolean micEnabled = false;

Gain g;
Glide gainGlide;

ControlTimer c;
Textlabel t;

ControlTimer c1;
Textlabel t1;

ControlTimer c2;
Textlabel t2;

Textlabel hourText;
Textlabel minText;
Textlabel secText;

Textlabel hourText1;
Textlabel minText1;
Textlabel secText1;

Textlabel hourText2;
Textlabel minText2;
Textlabel secText2;

int minuteValue = 0;
int hourValue = 0;
int secondValue = 0;

int minuteValue1 = 0;
int hourValue1 = 0;
int secondValue1 = 0;

int minuteValue2 = 0;
int hourValue2 = 0;
int secondValue2 = 0;

boolean timerOn = false;
boolean timerOn1 = false;
boolean timerOn2 = false;

String currentTts = "";
//end global variables

//runs once when the Play button above is pressed
void setup() {
  size(500, 500); //size(width, height) must be the first line in setup()

  ac = new AudioContext(); //AudioContext ac; is declared in helper_functions

  p5 = new ControlP5(this);

  tts = new TTS();

  mic = ac.getAudioInput();

  //timer
  frameRate(30);
  c = new ControlTimer();
  t = new Textlabel(p5,"--",0,0);
  c.setSpeedOfTime(0);

  c1 = new ControlTimer();
  t1 = new Textlabel(p5,"--",0 + 100,0);
  c1.setSpeedOfTime(0);

  c2 = new ControlTimer();
  t2 = new Textlabel(p5,"--",0 + 100 + 100,0);
  c2.setSpeedOfTime(0);

  //get sample player and pause playback
  cutting = getSamplePlayer("cutting.wav"); //add wav file name techno is filler
  cutting.pause(true);

  frying = getSamplePlayer("fryingSound.wav");
  frying.pause(true);

  oven = getSamplePlayer("oven.wav");
  oven.pause(true);

  contamination = getSamplePlayer("crossContamination.wav");
  contamination.pause(true);

  downTime = getSamplePlayer("downTime.wav");
  downTime.pause(true);

  salt = getSamplePlayer("saltSound.wav");
  salt.pause(true);

  pepper = getSamplePlayer("pepperSound.wav");
  pepper.pause(true);

  timerSound = getSamplePlayer("timer.wav");
  timerSound.pause(true);

  player = cutting;
  //glide to smoothly change overall gain
  gainGlide = new Glide(ac, 0.0, 0); //last input is delay
  g = new Gain(ac, 1, gainGlide);

  g.addInput(cutting);
  g.addInput(frying);
  g.addInput(oven);
  g.addInput(contamination);
  g.addInput(salt);
  g.addInput(pepper);
  g.addInput(downTime);
  g.addInput(timerSound);

  ac.out.addInput(g);

  ac.out.addInput(cutting);
  ac.out.addInput(frying);
  ac.out.addInput(oven);
  ac.out.addInput(contamination);
  ac.out.addInput(salt);
  ac.out.addInput(pepper);
  ac.out.addInput(downTime);
  ac.out.addInput(timerSound);

  //create ui
  p5.addButton("Play")
    .setPosition(width / 2 - 75, 275)
    .setSize(20, 20)
    .setLabel("Sound")
    .activateBy((ControlP5.RELEASE));

  p5.addButton("Stop")
    .setPosition(width / 2 - 50, 275)
    .setSize(20, 20)
    .setLabel("Stop")
    .activateBy((ControlP5.RELEASE));

  p5.addButton("Text")
    .setPosition(width / 2 + 30, 275)
    .setSize(20, 20)
    .setLabel("Text")
    .activateBy((ControlP5.RELEASE));

  p5.addSlider("GainSlider")
    .setPosition(width - 20, 20)
    .setSize(20, 200)
    .setRange(0.0, 200.0)
    .setValue(0)
    .setLabel("Gain");

  p5.addButton("StartTimer")
    .setLabel("start")
    .setPosition(0,10)
    .setSize(40,10);

  p5.addButton("reset")
    .setLabel("reset")
    .setPosition(0,20)
    .setSize(40,10);

  hourText = new Textlabel(p5,"hr",60,40);
  p5.addNumberbox("hour")
     .setLabel("")
     .setPosition(0,40)
     .setSize(60,10)
     .setRange(0,60)
     .setScrollSensitivity(0.1)
     .setDirection(Controller.HORIZONTAL)
     .setValue(0);

  minText = new Textlabel(p5,"min",60,60);
  p5.addNumberbox("minute")
    .setLabel("")
     .setPosition(0,60)
     .setSize(60,10)
     .setRange(0,60)
     .setDirection(Controller.HORIZONTAL) // change the control direction to left/right
     .setValue(0);

  secText = new Textlabel(p5,"sec",60,80);
  p5.addNumberbox("second")
    .setLabel("")
     .setPosition(0,80)
     .setSize(60,10)
     .setRange(0,60)
     .setDirection(Controller.HORIZONTAL) // change the control direction to left/right
     .setValue(0);

  p5.addButton("StartTimer1")
    .setLabel("start")
    .setPosition(0 + 100,10)
    .setSize(40,10);

  p5.addButton("reset1")
    .setLabel("reset")
    .setPosition(0 + 100,20)
    .setSize(40,10);

  hourText1 = new Textlabel(p5,"hr",60 + 100,40);
  p5.addNumberbox("hour1")
     .setLabel("")
     .setPosition(0 + 100,40)
     .setSize(60,10)
     .setRange(0,60)
     .setScrollSensitivity(0.1)
     .setDirection(Controller.HORIZONTAL)
     .setValue(0);

  minText1 = new Textlabel(p5,"min",60 + 100,60);
  p5.addNumberbox("minute1")
    .setLabel("")
     .setPosition(0 + 100,60)
     .setSize(60,10)
     .setRange(0,60)
     .setDirection(Controller.HORIZONTAL) // change the control direction to left/right
     .setValue(0);

  secText1 = new Textlabel(p5,"sec",60 + 100,80);
  p5.addNumberbox("second1")
    .setLabel("")
     .setPosition(0 + 100,80)
     .setSize(60,10)
     .setRange(0,60)
     .setDirection(Controller.HORIZONTAL) // change the control direction to left/right
     .setValue(0);

  p5.addButton("StartTimer2")
    .setLabel("start")
    .setPosition(0 + 100 + 100,10)
    .setSize(40,10);

  p5.addButton("reset2")
    .setLabel("reset")
    .setPosition(0 + 100 + 100,20)
    .setSize(40,10);

  hourText2 = new Textlabel(p5,"hr",60 + 100 + 100,40);
  p5.addNumberbox("hour2")
     .setLabel("")
     .setPosition(0 + 100 + 100,40)
     .setSize(60,10)
     .setRange(0,60)
     .setScrollSensitivity(0.1)
     .setDirection(Controller.HORIZONTAL)
     .setValue(0);

  minText2 = new Textlabel(p5,"min",60 + 100 + 100,60);
  p5.addNumberbox("minute2")
    .setLabel("")
     .setPosition(0 + 100 + 100,60)
     .setSize(60,10)
     .setRange(0,60)
     .setDirection(Controller.HORIZONTAL) // change the control direction to left/right
     .setValue(0);

  secText2 = new Textlabel(p5,"sec",60 + 100 + 100,80);
  p5.addNumberbox("second2")
    .setLabel("")
     .setPosition(0 + 100 + 100,80)
     .setSize(60,10)
     .setRange(0,60)
     .setDirection(Controller.HORIZONTAL) // change the control direction to left/right
     .setValue(0);

  List sound = Arrays.asList("cutting", "frying", "oven", "contamination", "salt", "pepper", "down time");
  /* add a ScrollableList, by default it behaves like a DropdownList */
  p5.addScrollableList("sounds")
     .setPosition(width / 2 - 75, 300)
     .setSize(width / 4 - 50, 100)
     .setBarHeight(20)
     .setItemHeight(20)
     .addItems(sound)
     // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
     ;

  List reminder = Arrays.asList("contamination", "frying", "done", "oil trick", "pound","marinade");
  /* add a ScrollableList, by default it behaves like a DropdownList */
  p5.addScrollableList("reminder")
     .setPosition(width / 2 + 5, 300)
     .setSize(width / 4 - 50, 100)
     .setBarHeight(20)
     .setItemHeight(20)
     .addItems(reminder)
     // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
     ;

  micEnable = p5.addRadioButton("micEnable")
      .setPosition(0, 100)
      .setSize(20, 10)
      .addItem("Enable Mic", 0.0);

  // p5.addScrollableList("sounds")
  //    .setPosition(width / 2 - 50, 120)
  //    .setSize(width / 2 - 50, 20)
  //    .setBarHeight(20)
  //    .setItemHeight(20)
  //    .addItems(l)
  //    // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
  //    ;

  ac.start();
}

//event handler
public void Play(int value) {
  println("pressed play");
  player.setToLoopStart();
  player.start();
}

public void Stop(int value) {
  println("pressed stop");
  player.setToEnd();
}

public void Text(int value) {
  println("pressed text");
  tts.speak(currentTts);
}

public void reset() {
  println("reset timer");
  c.setSpeedOfTime(0);
  c.reset();
  timerOn = false;
}

public void StartTimer() {
  println("start timer");
  timerOn = true;
  c.setSpeedOfTime(1);
  c.reset();
}

public void second(int sec) {
  secondValue = sec;
}

public void minute(int min) {
  minuteValue = min;
}

public void hour(int hr) {
  hourValue = hr;
}

public void reset1() {
  println("reset timer1");
  c1.setSpeedOfTime(0);
  c1.reset();
  timerOn1 = false;
}

public void StartTimer1() {
  println("start timer1");
  timerOn1 = true;
  c1.setSpeedOfTime(1);
  c1.reset();
}

public void second1(int sec) {
  secondValue1 = sec;
}

public void minute1(int min) {
  minuteValue1 = min;
}

public void hour1(int hr) {
  hourValue1 = hr;
}

public void reset2() {
  println("reset timer2");
  c2.setSpeedOfTime(0);
  c2.reset();
  timerOn2 = false;
}

public void StartTimer2() {
  println("start timer2");
  timerOn2 = true;
  c2.setSpeedOfTime(1);
  c2.reset();
}

public void second2(int sec) {
  secondValue2 = sec;
}

public void minute2(int min) {
  minuteValue2 = min;
}

public void hour2(int hr) {
  hourValue2 = hr;
}

public void GainSlider(float value) {
  gainGlide.setValue(value / 100.0);
}

void reminder(int n) {
  /* request the selected item based on index n */
  Map<String, Object> m = p5.get(ScrollableList.class, "reminder").getItem(n);
  Set<Map.Entry<String, Object>> set = m.entrySet();
  for (Map.Entry<String, Object> e : set) {
    if (e.getKey().equals("text")) {
      println(e.getValue());
    }
  }

  switch(n) {
    case 0:
      currentTts = "keep clean after cutting raw meat";
      break;
    case 1:
      currentTts = "check on the katsu";
      break;
    case 2:
      currentTts = "katsu should be done when golden brown";
      break;
    case 3:
      currentTts = "wood with steady bubbles in oil is 350 degrees";
      break;
    case 4:
      currentTts = "pound meat for even cooking";
      break;
    case 5:
      currentTts = "marinade between four to twenty four hours ";
      break;
  }

  /* here an item is stored as a Map  with the following key-value pairs:
   * name, the given name of the item
   * text, the given text of the item by default the same as name
   * value, the given value of the item, can be changed by using .getItem(n).put("value", "abc"); a value here is of type Object therefore can be anything
   * color, the given color of the item, how to change, see below
   * view, a customizable view, is of type CDrawable
   */

  CColor c = new CColor();
  c.setBackground(color(255,0,0));
  p5.get(ScrollableList.class, "reminder").getItem(n).put("color", c);

}

void sounds(int n) {
  /* request the selected item based on index n */
  Map<String, Object> m = p5.get(ScrollableList.class, "sounds").getItem(n);
  Set<Map.Entry<String, Object>> set = m.entrySet();
  for (Map.Entry<String, Object> e : set) {
    if (e.getKey().equals("text")) {
      println(e.getValue());
    }
  }

  player.setToEnd();
  switch(n) {
    case 0:
      player = cutting;
      break;
    case 1:
      player = frying;
      break;
    case 2:
      player = oven;
      break;
    case 3:
      player = contamination;
      break;
    case 4:
      player = salt;
      break;
    case 5:
      player = pepper;
      break;
    case 6:
      player = downTime;
      break;    
  }

  /* here an item is stored as a Map  with the following key-value pairs:
   * name, the given name of the item
   * text, the given text of the item by default the same as name
   * value, the given value of the item, can be changed by using .getItem(n).put("value", "abc"); a value here is of type Object therefore can be anything
   * color, the given color of the item, how to change, see below
   * view, a customizable view, is of type CDrawable
   */

  CColor c = new CColor();
  c.setBackground(color(255,0,0));
  p5.get(ScrollableList.class, "sounds").getItem(n).put("color", c);

}

// void keyPressed() {
//   switch(key) {
//     case('1'):
//       /* make the ScrollableList behave like a ListBox */
//       p5.get(ScrollableList.class, "sounds").setType(ControlP5.LIST);
//       break;
//     case('2'):
//       /* make the ScrollableList behave like a DropdownList */
//       p5.get(ScrollableList.class, "sounds").setType(ControlP5.DROPDOWN);
//       break;
//     case('3'):
//       /*change content of the ScrollableList */
//       List l = Arrays.asList("a-1", "b-1", "c-1", "d-1", "e-1", "f-1", "g-1", "h-1", "i-1", "j-1", "k-1");
//       p5.get(ScrollableList.class, "sounds").setItems(l);
//       break;
//     case('4'):
//       /* remove an item from the ScrollableList */
//       p5.get(ScrollableList.class, "sounds").removeItem("k-1");
//       break;
//     case('5'):
//       /* clear the ScrollableList */
//       p5.get(ScrollableList.class, "sounds").clear();
//       break;
//   }
// }

void correctInputs() {
    LinkedList<UGen> input = new LinkedList<UGen>();

    if (micEnabled) {
        input.add(mic);
    } else {
        input.add(player);
    }

    input.add(g);

    for (int i = 1; i < input.size(); i++) {
        input.get(i).clearInputConnections();
        input.get(i).addInput(input.get(i - 1));
    }
}

void micEnable(int i) {
    if (i == 0) {
        println("Mic Enabled");
        micEnabled = true;
    } else {
        println("Mic Disabled");
        micEnabled = false;
    }
    correctInputs();
}

void draw() {
  background(0);  //fills the canvas with black (0) each frame
  t.setValue(c.toString());
  t.draw(this);
  hourText.draw(this);
  minText.draw(this);
  secText.draw(this);

  t1.setValue(c1.toString());
  t1.draw(this);
  hourText1.draw(this);
  minText1.draw(this);
  secText1.draw(this);

  t2.setValue(c2.toString());
  t2.draw(this);
  hourText2.draw(this);
  minText2.draw(this);
  secText2.draw(this);

  String[] time = c.toString().split(":");
  int hr = Integer.parseInt(time[0].replaceAll("\\s+",""));
  int min = Integer.parseInt(time[1].replaceAll("\\s+",""));
  int sec = Integer.parseInt(time[2].replaceAll("\\s+",""));
  if (hr == hourValue && min == minuteValue && sec == secondValue && ((frameCount % 30) == 0) && timerOn) {
    println("timer reached");
    reset();
    // tts.speak("Time up");
    player = timerSound;
    player.setToLoopStart();
    player.start();
  }

  time = c1.toString().split(":");
  hr = Integer.parseInt(time[0].replaceAll("\\s+",""));
  min = Integer.parseInt(time[1].replaceAll("\\s+",""));
  sec = Integer.parseInt(time[2].replaceAll("\\s+",""));
  if (hr == hourValue1 && min == minuteValue1 && sec == secondValue1 && ((frameCount % 30) == 0) && timerOn1) {
    println("timer1 reached");
    reset1();
    // tts.speak("Time up");
    player = timerSound;
    player.setToLoopStart();
    player.start();
  }

  time = c2.toString().split(":");
  hr = Integer.parseInt(time[0].replaceAll("\\s+",""));
  min = Integer.parseInt(time[1].replaceAll("\\s+",""));
  sec = Integer.parseInt(time[2].replaceAll("\\s+",""));
  if (hr == hourValue2 && min == minuteValue2 && sec == secondValue2 && ((frameCount % 30) == 0) && timerOn2) {
    println("timer2 reached");
    reset2();
    // tts.speak("Time up");
    player = timerSound;
    player.setToLoopStart();
    player.start();
  }

}
