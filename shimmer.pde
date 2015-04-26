import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

import processing.video.*;

// Video stuff
int pixel_count;
int[] background_pixels;
Capture video;
PImage current_frame;
int frame_count;
int update_rate = 1;
int remembered_frames = 8;
ArrayList video_diffs = new ArrayList();
float brightness_threshold = 10.0;
boolean use_post_processing = true;

// Sound stuff
Minim minim;
AudioInput sound_in;
float eased_loudness = 0.0;
float easing = 0.5;

void setup() {
  size(1280, 960, P3D);
  
  video = new Capture(this, 640, 480);
  video.start();
  
  pixel_count = video.width * video.height;
  background_pixels = new int[pixel_count];
  frame_count = 0;
  
  minim = new Minim(this);
  sound_in = minim.getLineIn(Minim.MONO);
}

void save_current_difference() {
  video.read(); // Get a video frame
  video.loadPixels(); // Make the video.pixels array available
  current_frame = createImage(video.width, video.height, RGB);
  current_frame.loadPixels();
  arraycopy(video.pixels, current_frame.pixels);
  current_frame.updatePixels();
  PImage current_diff = createImage(video.width, video.height, RGB);
  current_diff.loadPixels();
  for (int pixel = 0; pixel < pixel_count; pixel++) {
    color pixel_color = video.pixels[pixel];
    
    color bg_pixel_color = background_pixels[pixel];
    
    int pixel_r = (pixel_color >> 16) & 0xFF;
    int pixel_g = (pixel_color >> 8) & 0xFF;
    int pixel_b = pixel_color & 0xFF;
    
    int bg_r = (bg_pixel_color >> 16) & 0xFF;
    int bg_g = (bg_pixel_color >> 8) & 0xFF;
    int bg_b = bg_pixel_color & 0xFF;
     
    int diff_r = abs(pixel_r - bg_r);
    int diff_g = abs(pixel_g - bg_g);
    int diff_b = abs(pixel_b - bg_b);
    
    current_diff.pixels[pixel] = color(diff_r, diff_g, diff_b);
  }
  current_diff.updatePixels();
  
  video_diffs.add(current_diff);
  
  // Only keep `remembered_frames` frames in memory
  if (video_diffs.size() > remembered_frames) {
    video_diffs.remove(0);
  }
}

void draw_explosion(PImage img) {
  background(0);
  int cellsize = 2;
  int columns = img.width / cellsize;
  int rows = img.height / cellsize;
  int x_border = (width - img.width) / 2;
  int y_border = (height - img.height) / 2;
  
  float current_loudness = sound_in.mix.level();
  float loudness_delta = current_loudness - eased_loudness;
  eased_loudness += loudness_delta * easing;
  for (int col = 0; col < columns; col++) {
    for (int row = 0; row < rows; row++) {
      int x = col*cellsize;
      int y = row*cellsize;
      int loc = x + (y * img.width);
      color c = img.pixels[loc];
      
      float z = 3.0 * eased_loudness * brightness(img.pixels[loc]) - 20.0;
      float rotation = PI/3.0 * ((float(width / 2) - float(mouseX)) / float(width));
      pushMatrix();
      //rotateY(rotation);
      translate(x + 300, y + 200, z + 50);
      //rotateY(-rotation);
      fill(c, 204);
      noStroke();
      rectMode(CENTER);
      rect(0, 0, cellsize, cellsize);
      popMatrix();
    } 
  }
}

void draw() {
  if (video.available()) {
    save_current_difference();
    
    for (int i = 0; i < video_diffs.size(); i++) {
      PImage diff = (PImage)video_diffs.get(i);
      diff.loadPixels();
    }
    PImage laggy_diff = createImage(video.width, video.height, RGB);
    laggy_diff.loadPixels();
    for (int pixel = 0; pixel < pixel_count; pixel++) {
      color pixel_color = #000000;
      int diff_frame = video_diffs.size() - 1;
      while (pixel_color == #000000 && diff_frame > 0) {
        PImage diff = (PImage)video_diffs.get(diff_frame);
        color diff_color = diff.pixels[pixel];
        if (brightness(diff_color) > brightness_threshold) {
          pixel_color = diff_color;
        }
        diff_frame--;
      }
      laggy_diff.pixels[pixel] = pixel_color;
    }
    laggy_diff.updatePixels();
    
    draw_explosion(laggy_diff);

    if (frame_count % update_rate == 0) {
      arraycopy(video.pixels, background_pixels);
    }
    frame_count++;
  }
}

void keyPressed() {
  
}















