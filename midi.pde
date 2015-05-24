import themidibus.*;

class KaossPadMidiListener implements SimpleMidiListener {
  private Boolean hold_held;
  private MidiBus kaoss_pad_bus;
  private boolean pad_x_stale;
  private boolean pad_y_stale;
  private int pad_down_x;
  private int pad_down_y;
  private Boolean pad_touched;
  private int screen_base_x;
  private int screen_base_y;
  
  public KaossPadMidiListener() {
    String[] available_inputs = MidiBus.availableInputs();
    for (int i = 0; i < available_inputs.length; i++) {
      if (available_inputs[i].startsWith("KP3 [")) {
        this.kaoss_pad_bus = new MidiBus(this, i, -1);
        break;
      }
    }
    this.kaoss_pad_bus.addMidiListener(this);
    this.hold_held = false;
    this.pad_x_stale = true;
    this.pad_y_stale = true;
    this.pad_down_x = 0;
    this.pad_down_y = 0;
    this.pad_touched = false;
    this.screen_base_x = 0;
    this.screen_base_y = 0;
  }
  
  public void controllerChange(int channel, int number, int value) {
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
      case 92: touchPadStatus(value); break;
      case 93: changeLevel(value); break;
      case 94: changeFXDepth(value); break;
      case 95: pressHold(value); break;
      default: break;  
    }
  }
  
  public void noteOff(int channel, int pitch, int velocity) {

  }
  
  public void noteOn(int channel, int pitch, int velocity) {
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
    if (pad_touched) {
      if (pad_x_stale) {
        pad_x_stale = false;
        pad_down_x = value;
      }
      x_offset = screen_base_x + expand(value - pad_down_x, 0, 1000);
    }
  }
  
  void touchPadY(int value) {
    if (pad_touched) {
      if (pad_y_stale) {
        pad_y_stale = false;
        pad_down_y = value;
      }
      y_offset = screen_base_y - expand(value - pad_down_y, 0, 1000);
    }
  }
  
  void touchPadStatus(int value) {
    Boolean status = value == 127;
    if (!status) {
      pad_x_stale = true;
      pad_y_stale = true;
    } else {
      screen_base_x = x_offset;
      screen_base_y = y_offset;
    }
    pad_touched = status;
  }
  
  void changeLevel(int value) {
    if (hold_held) {
      z_offset = expand(value, 100, 800);
    } else {
      loudness_boost = expand(value, 0.0, 20.0);
    }
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
    cell_shape = CellShape.ISOCELES;
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


