# SpatiaLiveRef

SpatialLiveRef is a software visualization visionOS app, created with the purpose of spatializing the LiveRef plug-in analysis. It provides an overview of refactoring suggestions for Java projects, using the city metaphor.

# Running instructions

To visualize your Java project within SpatialLiveRef you should follow this procedure:

1. Install LiveRef adapted plug-in for 2022 IntelliJ IDEA.
2. Install SpatialLiveRef on Apple Vision Pro.
3. Open one terminal on the spatial-liveref/scripts directory.
4. Run "python3 script1.py JAVA_PROJECT_PATH" to compute file analysis and wait for completion
5. Run "python3 script2.py JAVA_PROJECT_PATH" to populate database and wait for completion.
6. Run "python3 script3.py JAVA_PROJECT_PATH" to enable live updates. Alternatively, run "python3 script4.py JAVA_PROJECT_PATH" to only trigger file openings from building selections.

Note: you may need to create a virtual environment.

# SpatialLiveRef installation

To install SpatialLiveRef on your Apple Vision Pro headset, perform the following steps:
1. Pair Apple Vision Pro and macOS device.
2. Enable Developer mode on the headset and trust development team/user.
3. On your macOS device, open a terminal on the spatial-liveref/SpatialLiveRef directory.
4. Setup a Cloud Firestore application.
5. Run "" to open Xcode enabling Firebase for visionOS.
6. On Xcode, select building device as Apple Vision Pro and run to install the app.

Note: you may have to close and reopen Xcode multiple times to remove fake errors before building successfully.
