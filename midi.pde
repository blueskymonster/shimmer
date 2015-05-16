class KaossPadMidiListener implements SimpleMidiListener {
  private Boolean debug_mode;
  private Boolean hold_held;
  
  public KaossPadMidiListener(Boolean debug_mode) {
    this.debug_mode = debug_mode;
    this.hold_held = false;
  }
  
  void controllerChange(int channel, int number, int value) {
    if (debug_mode) {
      println("CONTROLLER CHANGE");
      println(channel);
      println(number);
      println(value);
    }
    switch (number) {
      case 49: changeCamera(number - 49, value); break;
      case 50: changeCamera(number - 49, value); break;
      case 51: changeCamera(number - 49, value); break;
      case 52: changeCamera(number - 49, value); break;
      case 53: changeCamera(number - 49, value); break;
      case 54: changeCamera(number - 49, value); break;
      case 55: changeCamera(number - 49, value); break;
      case 56: changeCamera(number - 49, value); break;
      case 70: touchPadX(value); break;
      case 71: touchPadY(value); break;
      case 93: changeLevel(value); break;
      case 94: changeFXDepth(value); break;
      case 95: pressHold(value); break;
      default: break;  
    }
  }
  
  void noteOff(int channel, int pitch, int velocity) {
    if (debug_mode) {
      println("NOTE OFF");
      println(channel);
      println(pitch);
      println(velocity);
    }
  }
  
  void noteOn(int channel, int pitch, int velocity) {
    if (debug_mode) {
      println("NOTE ON");
      println(channel);
      println(pitch);
      println(velocity);
    }
    switch (pitch) {
      case 36: pressA(); break;
      case 37: pressB(); break;
      case 38: pressC(); break;
      case 39: pressD(); break;
      default: break;
    }
  }
  
  private int expand(int midi_value, int lower_range, int higher_range) {
    if (midi_value == 0) {
      return lower_range;
    }
    float ratio = float(midi_value) / 128.0;
    int diff = higher_range - lower_range + 1;
    return int(ratio * float(diff) + float(lower_range));
  }
  
  private float expand(int midi_value, float lower_range, float higher_range) {
    if (midi_value == 0) {
      return lower_range;
    }
    float ratio = float(midi_value) / 128.0;
    float diff = higher_range - lower_range + 1;
    return ratio * diff + lower_range;
  }
  
  void touchPadX(int value) {
    x_offset = expand(value, 100, 600);
  }
  
  void touchPadY(int value) {
    y_offset = expand(value, 600, 100);
  }
  
  void changeLevel(int value) {
    loudness_boost = expand(value, 1.0, 20.0);
  }
  
  void changeFXDepth(int value) {
    cellsize_buffer = expand(value, 2, 40);
  }
  
  void pressA() {
    cell_shape = CellShape.RECTANGLE;
  }
  
  void pressB() {
    cell_shape = CellShape.CIRCLE;
  }
  
  void pressC() {
    
  }
  
  void pressD() {
    recordButtonPressed();
  }
  
  private void changeCamera(int camera, int midi_value) {
   if (midi_value == 127 && camera < camera_list.size()) {
      video = (Capture)camera_list.get(camera);
    } 
  }
  
  void pressHold(int value) {
      hold_held = value == 127;
  }
  
}


