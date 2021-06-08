import org.openkinect.processing.*;

Kinect2 kinect2;

// Depth image
PImage depthImg;
PImage lastImg;

PFont f;

int minDepth =  0;
int maxDepth =  1140; //4.5m

int[] oldDepth;
int[] depth;

// What is the kinect's angle
float angle;

float threshold = 50;

float lastSaturation;
float totalSaturation;
float totalMotion;
ArrayList<PoemWord> poemWords;

String poem = "An anchor, a grappling iron, something to overarm back to, author, date, grasp and clutch, ideas that fizz for days, slowly overtaken by another that blooms starfish bright, recedes in constellations you hop, then leap between & sometimes come a cropper, and still you grab and cling and over-reach, pluck a name and hold it ‘till it squeaks & splits, hook one name to the next, lights strung together, you start to ask – do you have any books on light? reading between split shifts, machinations of argument, unbreachable, plunge on, names scrawled on the back of your hand, late-night sand in your eyes, riffling back and forth through the book of all the words, spelling against you, always against you ‘till you figure it out, a breach in the sea-wall, you learn the word autodidact, loop it onto something else and now you’ve ballast, some heft to it, hand over hand, salt stinging, the long line of those who’ve done this too, who fought for time and space and quiet, travelling sideways, slowarm across the current, curlicues and dead calms, flailing in a sudden deeper channel, whole chunks of the jig-saw sky missing – do you have any books on the sky? stubbornness is what it boils down to, a coming back and coming back, knowing you’ll spell it wrong, pronounce it wrong, wrong wrong, clangs like a bell, split shift, back to the library – do you have any books on the rise of wage labour? bashing into walls of words, unball yourself on the street, new thoughts colliding like boiled sweets, ruby, lemon, turquoise, coalesce, re-form to constellations, plunge on, until you have your own son and he needs to know, not the grasp and clutch and swirling sand and jigsaw sky, instead, how sentences run from left to right, how the author’s name is on the side which is the spine, how you’re allowed to touch, and the one with all the words inside, turn the page, flip him loose till he slips and dives, comes back prattling of monsters and machines, fire-working turquoise, ruby, lemon, keep quiet, turn the pages, so that for him, this can be coming home. End";
// String poem = "Test the sound Test the sound Test the sound";
String[] words = split(poem, ' ');
int wordLength = words.length;

int counter = 0;
int  skip = 10;
int maxDistance = 250;
int dedicationOffset = 50;
float minSaturation = 0.5;
PFont titleFont;
PFont dedicationFont;


Boolean bubbles = false;
Boolean imageToggle = false;

int maxMotion = 20;
float finalMotion = 40;

void setup () {
  //  size (1920, 1080);
  fullScreen(P3D);

  titleFont = loadFont("CalendasPlus-Bold-40.vlw");
  dedicationFont = loadFont("Bould-ExtraLightItalic-40.vlw");
  // Kinect
  kinect2 = new Kinect2(this);
  kinect2.initDepth();
  kinect2.initDevice();
  depthImg = new PImage(kinect2.depthWidth, kinect2.depthHeight);
  lastImg = new PImage(kinect2.depthWidth, kinect2.depthHeight);

  depth = kinect2.getRawDepth();
  oldDepth = kinect2.getRawDepth();

  // Initialise word ArrayList

  poemWords = new ArrayList<PoemWord>();

  for (int i = 0; i < wordLength; i++) {
    poemWords.add(new PoemWord(i, words));
  }

  // Set font
  PFont poemFont;
  poemFont = loadFont("Title.vlw");
};





void draw() {
  background (255);

  int counter = 0;

  oldDepth = depth;
  depth = kinect2.getRawDepth();
  float totalSaturation = 0;
  float totalMotion = 0;

  for (int i=0; i < depth.length; i++) {

    float diff = abs(depth[i] - oldDepth[i]);

    totalMotion += diff;



    if (depth[i] >= minDepth && depth[i] <= maxDepth) {
      float ratio = (maxDepth - minDepth)/255.0;
      depthImg.pixels[i] = color((depth[i] - minDepth)/ratio);

      if (color((depth[i] - minDepth)) >= 0) {
        totalSaturation += color((depth[i] - minDepth));
      }
    } else {
      depthImg.pixels[i] = color(0);
    }
  }

  float avgMotion = totalMotion / depth.length;

  finalMotion = lerp(finalMotion, avgMotion, 0.1);


  // Draw the thresholded image
  depthImg.updatePixels();
  if (imageToggle == true) {

    image(depthImg, 0, 0);
  }
  tint(255, 126);






  // Iterate through the kinect pixels
  for (int y = 0; y < kinect2.depthHeight; y += 8) {

    for (int x = 0; x < kinect2.depthWidth; x += (textWidth(words[(abs(counter - 1)) % words.length]) / 2.8)) {


      int index = x + y * kinect2.depthWidth;
      float distance = depth[index];

      PVector pixelPosition;
      pixelPosition = new PVector (x, y, distance);

      if (distance > minDepth && distance < maxDepth && counter < wordLength - 1) {
        fill(0, 102, 153);

        if (bubbles == true) {
          circle (pixelPosition.x, pixelPosition.y, distance / 50);
        }


        PoemWord w = poemWords.get(counter);
        w.positionChange(pixelPosition);

        counter ++;
      }
    }
  }

  // totalMotion = lerp(totalMotion, lastMotion / 10000, 0.9);
  totalMotion = abs(lerp(totalMotion, (lastSaturation - totalSaturation), 0.08));


  // ellipse(width/2, ((totalMotion)/height), 55, 55);



  fill(0, 0, 0);

  // circle (400, height - totalMotion, 50);

  if (imageToggle == true) {

    //      text("Total Motion: [" + totalMotion "]", 10, 36);

    text(("TOTAL SATURATION:"+ totalSaturation ), 10, 56);
    //text(("LAST SATURATION:"+ lastSaturation), 10, 76);
    text(("AVG MOTION:"+ avgMotion), 10, 96);
  }


  for (PoemWord w : poemWords) {
    w.update(counter, totalSaturation);
    w.display();
  }

  lastSaturation = totalSaturation;

  fill(70);

  textSize(40);
  textAlign(CENTER);

  textFont (titleFont);
  String title = "Autodidact";
  text(title, width/2, 70, 0);
  strokeWeight(2);
  stroke (70);
  // line(width/2 - textWidth(title)/1.8, 80, width/2 + textWidth(title)/1.8, 80);
  
  textFont (dedicationFont);
  textAlign(LEFT);
  textSize(20);
    text ("Commissioned for Manchester City of Literature's Festival of Libraries 2021", dedicationOffset, height - 180);
    text ("with Manchester Poetry Library", dedicationOffset, height - 155);
  text ("Technology by David McFarlane (@dvd_mcf)", dedicationOffset, height - 130);
  text ("Poetry by Charlotte Wetton (@CharPoetry)", dedicationOffset, height - (105) );

  text ("With thanks to Future Everything and The Writing Squad", dedicationOffset, height - (80) );
  text ("#FestivalofLibraries", dedicationOffset, height - (55) );
 text ("www.manchestercityofliterature.com", dedicationOffset, height - (30) );

}










void keyPressed() {
  if (key == 'a') {
    minDepth = constrain(minDepth+100, 0, maxDepth);
  } else if (key == 's') {
    minDepth = constrain(minDepth- 100, 0, maxDepth);
  } else if (key == 'z') {
    maxDepth = constrain(maxDepth+100, minDepth, 1165952918);
  } else if (key =='x') {
    maxDepth = constrain(maxDepth-100, minDepth, 1165952918);
  } else if (key == 'b') {
    bubbles =! bubbles;
  } else if (key == 'i') {
    imageToggle =! imageToggle;
  }
}




class PoemWord {

  String thisWord = "";

  int index;

  PVector restPosition;
  PVector restVelocity;

  PVector position;
  PVector lastPosition;
  PVector velocity;
  PVector acceleration;
  PVector target;
  PVector newTarget;

  float topspeed;
  float easing;
  int alpha;
  int alpha2;
  int jumpFlag;

  float pixelDistance;

  float brightness = 0;

  int fadeSpeed = 10;


  //depthimg = 512 *424

  int heightRatio = height/kinect2.depthHeight;
  int widthRatio = width/kinect2.depthWidth;

  float threshold = 1000;

  PFont poemFont;


  PoemWord(int indexTemp, String [] wordsTemp) {

    topspeed = 0.001;

    poemFont = loadFont("Argesta.vlw");
    textFont(poemFont);

    index = indexTemp;
    thisWord = wordsTemp[index];

    restPosition = new PVector(random(width * 2) - width, random(height * 2) - height, -random(2000));
    restVelocity = new PVector(random(2) - 1, random(2) - 1);
    position = new PVector(random(width), random(height), -random(20));
    target = new PVector(0, 0, 0);
    newTarget = new PVector(0, 0, 0);


    velocity = new PVector(0, 0, 0);
    acceleration = new PVector(0, 0, 0);

    //   target = new PVector(0, 0, 0);
    easing = 0.5;
    alpha = 255;
    alpha2 = 0;
    jumpFlag = 1;
    pixelDistance = 255;
    counter = 0;
  }



  void positionChange(PVector tempVector) {

    tempVector.x =  (tempVector.x * widthRatio) ;
    tempVector.y = (tempVector.y * heightRatio) ;
    pixelDistance = map(tempVector.z, 0, 255, 0, 255);
    tempVector.z = map(tempVector.z, minDepth, maxDepth, 150, 0);
    velocity.limit(topspeed);


    if (finalMotion > maxMotion) {
      target =  tempVector;
    }
  };

  void positionChange() {
    target = lastPosition;
  };



  void update(int tempCounter, float tempSaturation) {

tempSaturation = tempSaturation / 10000000 ;
    if (finalMotion > maxMotion) {
      counter = tempCounter;
    }

    newTarget = target.copy();
    newTarget.sub(position);
    velocity = newTarget;
    restPosition.add(restVelocity);
  

    if ((this.index < counter) && (tempSaturation > minSaturation)) {
      if (dist(target.x, target.y, position.x, position.y) < maxDistance) {
        position = position.lerp(target, 0.05);

      } else {

        velocity = new PVector (0, 0, 0);
        acceleration = new PVector (0, 0, 0);
        position = position.lerp(target, 0.95);
      }

      brightness = map (position.z, 0, - 20, 70, 255);
    } else {

      if (restPosition.x > width*2) {
        position.x = 0 - width;
        restPosition.x = 0 - width;
      }
      if (restPosition.x < 0 - width) {
        position.x = width * 2;
        restPosition.x = width * 2;
      }

      if (restPosition.y > height * 2) {
        position.y = 0 - height;
        restPosition.y = 0 - height;
      }
      if (restPosition.y < 0 - height) {
        position.y = height * 2;
        restPosition.y = height * 2;
      }

      position = position.lerp(restPosition, 0.01);
      brightness = 150;
      //  velocity = restVelocity;
    }
  }






  void display() {

    textFont(poemFont);
    textAlign(LEFT, CENTER);
    textSize(15);

    // float brightness = map (position.z, 0, 255, 100, 255);
    //   float brightness = map(position.z, -50, 150, 150, 0);
    fill(brightness, brightness, brightness, alpha);
    //alpha = constrain(alpha + fadeSpeed, 0, 255);

    text(thisWord, position.x, position.y, position.z);
  }
}

void updateDepth(int maxDepthInput, int minDepthInput) {

  maxDepth = maxDepthInput;
  minDepth = minDepthInput;
}
