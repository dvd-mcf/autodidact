import org.openkinect.processing.*;

Kinect2 kinect2;

// Depth image
PImage depthImg;
PImage lastImg;

PFont f;

int minDepth =  0;
int maxDepth =  1140; //4.5m

// What is the kinect's angle
float angle;

float threshold = 50;

float lastSaturation; 
float totalSaturation;
float totalMotion;
ArrayList<PoemWord> poemWords;

String poem = "An anchor here, a grappling iron there, something to overarm back to, an author, a date, chartless you plunge on, grasp and clutch, the freight, sand in your eyes from staying up late, you learn the word autodidact, loop it onto something else and now you’ve ballast, some heft to it, hand over hand, salt stinging, the long line of those who’ve done this too, who fought for time and space and quiet, sideways slow arm over arm across the current, curlicues and dead calms, flailing in a sudden deeper channel, ideas that fizz for weeks, only slowly overtaken by another that blooms dahlia bright, recedes in constellations, new friends you hopped then leapt between and sometimes came a cropper, and still you grabbed and clung and over-reached, plucked a name from the air and held it ‘till it squeaked and split, you’d ask for help when you had the words, how can you ask do you have any books on words? name on name, hook one to the next, like lights you strung together, you start to ask do you have any books on light? machinations of argument, unbreachable, reading between split shifts on a bench, plunge on, out late, names, scrawled on serviettes, on bus tickets, home half pissed, sand in your eyes, riffling back and forth through the dictionary, spelling against you, always against you, ‘till you figure it out, write it out, a breach in the sea-wall of someone else’s text, stubbornness is what it boils down to, a coming back and coming back, knowing you’d spell it wrong, pronounce it wrong, wrong wrong, clangs like a bell, a refusal to admit defeat, split shifts, back to the library, bashing into walls of words, do you have any books on the rise of wage labour? Eyes hungry, hands hungry, unball yourself on the street, new thoughts colliding like boiled sweets, ruby, lemon, turquoise, coalesce, re-form, you come round by naming, bicycle small dog, whole chunks of this jig-saw sky are missing, do you have any books on the sky? Channels deepen merge, plunge on, build a constellation, then another, until you have your own son and he needs to know, not the grasp and clutch and the swirling sand and the jigsaw sky, instead pretend that this is his, the sentences that run from left to right, the names along the spine, the books you’re allowed to touch, show him the book with the words in, keep quiet about the rest, turn the pages for him, flip him loose till he slips the halter of time and place, dives, submerged, comes back prattling of monsters and machines fire-working in him, turquoise, ruby, lemon, and somersaults again and back, you keep quiet and turn the pages so that for him this can be coming home. End";
// String poem = "Test the sound Test the sound Test the sound";
String[] words = split(poem, ' ');
int wordLength = words.length;

int counter = 0;
int  skip = 4;
int maxDistance = 250; 



Boolean bubbles = true;
Boolean imageToggle = true;

int maxMotion = 50;
float lastMotion;

void setup () {
  size (1920, 1080);
  //fullScreen(P3D, 2);

  // Kinect
  kinect2 = new Kinect2(this);
  kinect2.initDepth();
  kinect2.initDevice();
  depthImg = new PImage(kinect2.depthWidth, kinect2.depthHeight);
  lastImg = new PImage(kinect2.depthWidth, kinect2.depthHeight);




  // Initialise word ArrayList

  poemWords = new ArrayList<PoemWord>();

  for (int i = 0; i < wordLength; i++) {
    poemWords.add(new PoemWord(i, words));
  }

  // Set font
  PFont poemFont;
  poemFont = loadFont("Argesta.vlw");
  textFont(poemFont); 

  textAlign(LEFT, CENTER);

  
};





void draw() {
  background (255);

  int counter = 0;
  int[] depth = kinect2.getRawDepth();
  float totalSaturation = 0;



  for (int i=0; i < depth.length; i++) {
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




  // Draw the thresholded image
  depthImg.updatePixels();
  if (imageToggle == true) { 

    image(depthImg, 0, 0);
  }
  tint(255, 126);






  // Iterate through the kinect pixels
  for (int y = 0; y < kinect2.depthHeight; y += skip * 1.5) {
    
    for (int x = 0; x < kinect2.depthWidth; x += (skip * words[(abs(counter - 1)) % words.length].length())) {   


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

    totalMotion = lerp(totalMotion, lastMotion / 10000, 0.1);
  

  fill(0, 0, 0);
  textSize(25);

  // circle (400, height - totalMotion, 50);

  /*
          text("THRESHOLD: [" + minDepth + ", " + maxDepth + "]", 10, 36);
   
   text(("TOTAL SATURATION:"+ totalSaturation), 10, 56);
   text(("LAST SATURATION:"+ lastSaturation), 10, 76);
   text(("TOTAL MOTION:"+ totalMotion), 10, 96);
   */



  for (PoemWord w : poemWords) {
    w.update(counter);

    w.display();
  }
  lastMotion = totalMotion;
}










void keyPressed() {
  if (key == 'a') {
    minDepth = constrain(minDepth+10, 0, maxDepth);
  } else if (key == 's') {
    minDepth = constrain(minDepth-10, 0, maxDepth);
  } else if (key == 'z') {
    maxDepth = constrain(maxDepth+10, minDepth, 1165952918);
  } else if (key =='x') {
    maxDepth = constrain(maxDepth-10, minDepth, 1165952918);
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

    restPosition = new PVector(random(width), random(height), -random(200));
    restVelocity = new PVector(random(width), random(height), 0);
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

  }



  void positionChange(PVector tempVector) {

    tempVector.x =  (tempVector.x * widthRatio) ;
    tempVector.y = (tempVector.y * heightRatio) ;
    pixelDistance = map(tempVector.z, 0, 255, 0, 255);
    tempVector.z = map(tempVector.z, minDepth, maxDepth, 150, 0);
    velocity.limit(topspeed);


  //  if (totalMotion > maxMotion) {
      target =  tempVector;
 //   }
  };

  void positionChange() {

    target = lastPosition;
  };



  void update(int tempCounter) {
    newTarget = target.copy();
    newTarget.sub(position);
    velocity = newTarget;
    
    
    
    
    if (this.index < tempCounter) {
      if (dist(target.x, target.y, position.x, position.y) < maxDistance) {
        position = position.lerp(target, 0.15);
        // position.add(velocity.mult(easing));
      } else {
        //  position.add(velocity);
        velocity = new PVector (0, 0, 0);
        acceleration = new PVector (0, 0, 0);
        position = position.lerp(target, 0.95);
      }

 
    } else {
      position = position.lerp(restPosition, 0.05);
      velocity = restVelocity;
    }
  }






  void display() {
    textSize(14);


 


    // float brightness = map (position.z, 0, 255, 100, 255);
    float brightness = map(position.z, -50, 150, 150, 0);
    fill(brightness, brightness, brightness, alpha);
    //alpha = constrain(alpha + fadeSpeed, 0, 255);

    text(thisWord, position.x, position.y, 0);
  }
}

void updateDepth(int maxDepthInput, int minDepthInput) {

  maxDepth = maxDepthInput;
  minDepth = minDepthInput;
}
