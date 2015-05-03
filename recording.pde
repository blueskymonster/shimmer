import java.util.Date;

void bufferRecording() {
  if (recording) {
    loadPixels();
    PImage current_frame = createImage(width, height, RGB);
    current_frame.loadPixels();
    arraycopy(pixels, current_frame.pixels);
    current_frame.updatePixels();
    recording_buffer.add(current_frame);
  }
}

void toggleRecording() {
  if (!recording) {
    Date now = new Date();
    recording_folder = dataPath(date_format.format(now));
  } else {
    int frame_number = 0;
    while (recording_buffer.size() > 0) {
      PImage frame_to_save = (PImage)recording_buffer.remove(0);
      frame_to_save.save(recording_folder + String.format("/frame-%06d.jpg", frame_number));
      frame_number++;
    }
  }
  recording = !recording;
}

