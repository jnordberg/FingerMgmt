
typedef struct {
	float x;
	float y;
} mtPoint;

typedef struct {
	mtPoint position;
	mtPoint velocity;
} mtVector;

typedef struct {
  int frame; // the current frame
  double timestamp; // event timestamp
	int identifier; // identifier guaranteed unique for life of touch per device
	int state; //the current state (not sure what the values mean)
	int unknown1; //no idea what this does
	int unknown2; //no idea what this does either
	mtVector normalized; //the normalized position and vector of the touch (0,0 to 1,1)
	float size; //the size of the touch (the area of your finger being tracked)
	int unknown3; //no idea what this does
	float angle; //the angle of the touch            -|
	float majorAxis; //the major axis of the touch   -|-- an ellipsoid. you can track the angle of each finger!
	float minorAxis; //the minor axis of the touch   -|
	mtVector unknown4; //not sure what this is for
	int unknown5[2]; //no clue
	float unknown6; //no clue
} mtTouch;

typedef void *MTDeviceRef; //a reference pointer for the multitouch device
typedef int (*MTContactCallbackFunction)(int,mtTouch*,int,double,int); //the prototype for the callback function

MTDeviceRef MTDeviceCreateDefault(); //returns a pointer to the default device (the trackpad)
CFMutableArrayRef MTDeviceCreateList(void); //returns a CFMutableArrayRef array of all multitouch devices
void* MTRegisterContactFrameCallback(MTDeviceRef, MTContactCallbackFunction); //registers a device's frame callback to your callback function
void MTDeviceStart(MTDeviceRef, int); //start sending events
