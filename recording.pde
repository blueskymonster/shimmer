import java.util.Date;
import java.text.SimpleDateFormat;

void recordOutput() {
  if (recording) {
    saveFrame("/frame-######.png");
  }
}

void toggleRecording() {
  if (!recording) {
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
    Date now = new Date();
    recording_folder = dataPath(sdfDate.format(now));
  }
  recording = !recording;
}

