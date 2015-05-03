void toggleSoundMonitoring() {
  if (sound_in.isMonitoring()) {
    sound_in.disableMonitoring();
  } else {
    sound_in.enableMonitoring();
  }
}

void recordButtonPressed() {
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
}

void handleOtherKeys() {
  if (key >= '0' && key <= '9') {
    int number = Character.getNumericValue(key);
    if (number < camera_list.size()) {
      video = (Capture)camera_list.get(number);
    }
  }
}

void handleCodedKeys() {
  if (keyCode == UP) {
    cellsize += 1;
  } else if (keyCode == DOWN) {
    if (cellsize > 1) {
      cellsize -= 1;
    }
  }
}

void keyPressed() {
  switch (key) {
    case ' ': recordButtonPressed();
              break;
    case 's': toggleSoundMonitoring();
              break;
    case CODED: handleCodedKeys();
                break;
    default: handleOtherKeys();
  }
}
