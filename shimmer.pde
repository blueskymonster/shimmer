import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

import processing.video.*;


void setup() {
  size(1280, 960, P3D);
  
  for (int cam = 0; cam < camera_count; cam++) {
    Capture camera = new Capture(this, 640, 480, "/dev/video" + str(cam));
    camera.start();
    camera_list.add(camera);
  }
  
  video = (Capture)camera_list.get(0);
  
  VIDEO_PIXEL_COUNT = video.width * video.height;
  background_pixels = new int[VIDEO_PIXEL_COUNT];
  frame_count = 0;
  
  minim = new Minim(this);
  sound_in = minim.getLineIn(Minim.STEREO);
  //file_player = minim.loadFile("/home/elliot/Dropbox/Music/Bleep Bloop - Feel the Cosmos (MP3)/Bleep Bloop - Bleep Bloop - Feel The Cosmos (STRTEP028) - 01 Something Impossible.mp3");
  //file_player.play();
}

ArrayList get_current_bg_loop() {
  if (using_bg_loop1) {
    return bg_loop1;
  } else {
    return bg_loop2;
  }
}

void save_current_difference() {
  video.read(); // Get a video frame
  video.loadPixels(); // Make the video.pixels array available
  record_bg_loop();
  PImage current_diff = createImage(video.width, video.height, RGB);
  current_diff.loadPixels();
  for (int pixel = 0; pixel < VIDEO_PIXEL_COUNT; pixel++) {
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

PImage create_laggy_diff() {
  for (int i = 0; i < video_diffs.size(); i++) {
    PImage diff = (PImage)video_diffs.get(i);
    diff.loadPixels();
  }
  PImage laggy_diff = createImage(video.width, video.height, RGB);
  laggy_diff.loadPixels();
  for (int pixel = 0; pixel < VIDEO_PIXEL_COUNT; pixel++) {
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
  return laggy_diff;
}

void draw_explosion(PImage img) {
  background(0);
  int cellsize = 6;
  int columns = img.width / cellsize;
  int rows = img.height / cellsize;
  int x_border = (width - img.width) / 2;
  int y_border = (height - img.height) / 2;
  
  float current_loudness = loudness_boost * sound_in.mix.level();
  float loudness_delta = current_loudness - eased_loudness;
  eased_loudness += loudness_delta * easing;
  int rotation_speed = 20;
  float rotation = PI/3.0 * sin( float((frame_count % rotation_speed) - (rotation_speed / 2)) / float(rotation_speed)); 
  for (int col = 0; col < columns; col++) {
    for (int row = 0; row < rows; row++) {
      int x = col*cellsize;
      int y = row*cellsize;
      int loc = x + (y * img.width);
      color c = img.pixels[loc];
      
      float z = 5.0 * current_loudness * brightness(img.pixels[loc]) - 20.0;
      pushMatrix();
      //rotateY(rotation);
      translate(x + 300, y + 200, z + 200);
      //rotateY(-rotation);
      fill(c, 204);
      noStroke();
      //rectMode(CENTER);
      float z_scaling = 1000.0;
      ellipse(0, 0, cellsize + round(z / z_scaling), cellsize + round(z / z_scaling));
      popMatrix();
    } 
  }
}

void record_bg_loop() {
  if (record_loop && frame_count % update_rate == 0) {
    PImage current_frame = createImage(video.width, video.height, RGB);
    arraycopy(video.pixels, current_frame.pixels);
    current_frame.updatePixels();
    if (using_bg_loop1) {
      bg_loop2.add(current_frame);
    } else {
      bg_loop1.add(current_frame);
    }
  }
}

void update_bg_frame() {
  if (get_current_bg_loop().size() == 0) {
    arraycopy(video.pixels, background_pixels);
  } else {
    int loop_length = get_current_bg_loop().size();
    int loop_idx = abs((frame_count % (2 * loop_length - 1)) - (loop_length - 1));
    
    PImage bg_frame = (PImage)(get_current_bg_loop().get(loop_idx));
    arraycopy(bg_frame.pixels, background_pixels);
  }
}

void draw() {
  if (video.available()) {
    save_current_difference();
    
    PImage laggy_diff = create_laggy_diff(); 
    
    draw_explosion(create_laggy_diff());

    update_bg_frame();
    
    frame_count++;
  }
}

void keyPressed() {
  if (key == ' ') {
    if (!record_loop) {
      if (using_bg_loop1) {
        bg_loop2.clear();
      } else {
        bg_loop1.clear();
      }
    } else {
      using_bg_loop1 = !using_bg_loop1;
    }
    record_loop = !record_loop;
  } else if (key >= '0' && key <= '9') {
    int number = Character.getNumericValue(key);
    if (number < camera_list.size()) {
      video = (Capture)camera_list.get(number);
    }
  }
}




