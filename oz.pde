import controlP5.*;
import beads.*;
import org.jaudiolibs.beads.*;
import java.util.*;
import guru.ttslib.*;

//declare global variables at the top of your sketch
//AudioContext ac; is declared in helper_functions

ControlP5 p5;
ControlTimer c;
Textlabel t;
TTS tts;

SamplePlayer frying;
SamplePlayer oven;
SamplePlayer cutting;
SamplePlayer player;

RadioButton micEnable;
UGen mic;
boolean micEnabled = false;

Gain g;
Glide gainGlide;

Textlabel hourText;
Textlabel minText;
Textlabel secText;

int minuteValue = 0;
int hourValue = 0;
int secondValue = 0;

boolean timerOn = false;
String currentTts = "";
//end global variables

//runs once when the Play button above is pressed
void setup() {
  size(320, 240); //size(width, height) must be the first line in setup()

  ac = new AudioContext(); //AudioContext ac; is declared in helper_functions

  p5 = new ControlP5(this);

  tts = new TTS();

  mic = ac.getAudioInput();

  //timer
  frameRate(30);
  c = new ControlTimer();
  t = new Textlabel(p5,"--",0,0);
  c.setSpeedOfTime(0);

  //get sample player and pause playback
  cutting = getSamplePlayer("cutting.wav"); //add wav file name techno is filler
  cutting.pause(true);

  frying = getSamplePlayer("frying.wav");
  frying.pause(true);

  oven = getSamplePlayer("oven.wav");
  oven.pause(true);

  player = cutting;
  //glide to smoothly change overall gain
  gainGlide = new Glide(ac, 0.0, 0); //last input is delay
  g = new Gain(ac, 1, gainGlide);

  g.addInput(cutting);
  g.addInput(frying);
  g.addInput(oven);

  ac.out.addInput(g);

  ac.out.addInput(cutting);
  ac.out.addInput(frying);
  ac.out.addInput(oven);

  //create ui
  p5.addButton("Play")
    .setPosition(width / 2 - 50, 100)
    .setSize(20, 20)
    .setLabel("Sound")
    .activateBy((ControlP5.RELEASE));

  p5.addButton("Text")
    .setPosition(width / 2 + 30, 100)
    .setSize(20, 20)
    .setLabel("Text")
    .activateBy((ControlP5.RELEASE));

  p5.addSlider("GainSlider")
    .setPosition(300, 20)
    .setSize(20, 100)
    .setRange(0.0, 100.0)
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

  hourText = new Textlabel(p5,"hr",100,40);
  p5.addNumberbox("hour")
     .setLabel("")
     .setPosition(0,40)
     .setSize(100,10)
     .setRange(0,60)
     .setScrollSensitivity(0.1)
     .setDirection(Controller.HORIZONTAL)
     .setValue(0);

  minText = new Textlabel(p5,"min",100,60);
  p5.addNumberbox("minute")
    .setLabel("")
     .setPosition(0,60)
     .setSize(100,10)
     .setRange(0,60)
     .setDirection(Controller.HORIZONTAL) // change the control direction to left/right
     .setValue(0);

  secText = new Textlabel(p5,"sec",100,80);
  p5.addNumberbox("second")
    .setLabel("")
     .setPosition(0,80)
     .setSize(100,10)
     .setRange(0,60)
     .setDirection(Controller.HORIZONTAL) // change the control direction to left/right
     .setValue(0);

  List sound = Arrays.asList("cutting", "frying", "oven");
  /* add a ScrollableList, by default it behaves like a DropdownList */
  p5.addScrollableList("sounds")
     .setPosition(width / 2 - 110, 120)
     .setSize(width / 2 - 50, 100)
     .setBarHeight(20)
     .setItemHeight(20)
     .addItems(sound)
     // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
     ;

  List reminder = Arrays.asList("contamination", "frying", "done");
  /* add a ScrollableList, by default it behaves like a DropdownList */
  p5.addScrollableList("reminder")
     .setPosition(width / 2, 120)
     .setSize(width / 2 - 50, 100)
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
      currentTts = "remember to be clean after cutting raw meat";
      break;
    case 1:
      currentTts = "check on the katsu";
      break;
    case 2:
      currentTts = "katsu should be done when golden brown";
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

  String[] time = c.toString().split(":");
  int hr = Integer.parseInt(time[0].replaceAll("\\s+",""));
  int min = Integer.parseInt(time[1].replaceAll("\\s+",""));
  int sec = Integer.parseInt(time[2].replaceAll("\\s+",""));
  if (hr == hourValue && min == minuteValue && sec == secondValue && ((frameCount % 30) == 0) && timerOn) {
    println("timer reached");
    reset();
    tts.speak("You have reached the chosen time");
  }
}
