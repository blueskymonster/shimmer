// Video stuff
int VIDEO_PIXEL_COUNT;  // Number of pixels in video feeds. Do not alter manually.
int[] background_pixels;  // Current frame being used to subtract from video feed
ArrayList camera_list =  new ArrayList();  // The connected camera objects
int camera_count = 2;  // How many cameras to attempt to connect to
Capture video;  // Pointer to the camera object currently being read from
int frame_count;  // How many frames have been rendered since the beginning  of runtime.
int update_rate = 1;  // modulo of frames to record into bg_loops
int remembered_frames = 2;  // How long a buffer to maintain for stacking subtraction signals. 2 is minimum.
ArrayList video_diffs = new ArrayList();  // Where the remembered frames are stored
float brightness_threshold = 10.0;  // Brightness threshold used when stacking frames.

// Video recording
import java.text.SimpleDateFormat;
SimpleDateFormat date_format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
boolean recording = false;
String recording_folder = "";
ArrayList recording_buffer = new ArrayList();  // recorded video is buffered here before writing to disk

// Video loop data
boolean record_loop = false;  // Are we currently recording a loop?
boolean using_bg_loop1 = false;  // Which bg_loop are we currently displaying?
ArrayList bg_loop1 = new ArrayList();
ArrayList bg_loop2 = new ArrayList();

// Sound stuff
Minim minim;
AudioInput sound_in;
AudioPlayer file_player;
float loudness_boost = 8.0;  // Boosts the pixel's z-responsiveness to the sound level
float eased_loudness = 0.0;  // Current "eased loudness". Do not alter manually.
float easing = 1.0;  // 1.0 = instant. smaller values slowly move towards the current loudness

// 3D stuff
int cellsize_buffer = 6; // Used to only change cellsize during the frame 
int cellsize = cellsize_buffer;  // Base size of color shape
int x_offset = 300;
int y_offset = 200;
int z_offset = 200;
float x_rotation_factor = 0.0; // 0.005;  // How quickly to rotate in x direction
float x_rotation_limit = PI / 15.0; // How far to rotate in either x direction
float y_rotation_factor = 0.0; // 0.016;  // How quickly to rotate in y direction
float y_rotation_limit = PI / 12.0; // How far to rotate in either y direction
float z_scaling = 0.003;
CellShape cell_shape = CellShape.RECTANGLE;

// MIDI stuff
KaossPadMidiListener kaoss_pad = new KaossPadMidiListener();

