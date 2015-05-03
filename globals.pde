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

// Video loop data
boolean record_loop = false;  // Are we currently recording a loop?
boolean using_bg_loop1 = false;  // Which bg_loop are we currently displaying?
ArrayList bg_loop1 = new ArrayList();
ArrayList bg_loop2 = new ArrayList();


// Sound stuff
Minim minim;
AudioInput sound_in;
AudioPlayer file_player;
float loudness_boost = 5.0;  // Boosts the pixel's z-responsiveness to the sound level
float eased_loudness = 0.0;  // Current "eased loudness". Do not alter manually.
float easing = 0.5;  // 0.0 = instant. larger values slowly move towards the current loudness