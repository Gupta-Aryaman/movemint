<p align="center">
  <!--   
  <a href="https://github.com/Gupta-Aryaman/smooth-moves">
   // add logo here
  </a> 
  -->

  <h1 align="center">Smooth Moves</h1>
  <p align="center">
    <i>Now anyone can be independent!</i>
  </p>
</p>

Our objective is to develop an application aimed at simplifying (movement free) triggering of automation tasks through the use of an EEG headset.

## About the project
![unnamed](https://github.com/Gupta-Aryaman/smooth-moves/assets/34962578/1c721bc7-f2c9-4984-9e52-1c55cd010e97)


## What are we using?
1. Emotiv API (tested with EPOC X only, but should work with any emotiv headset)
2. Swift - for creating iOS app
3. Python - as a client to Emotiv WSS Server
4. iOS Shortcuts App - to create automations, which would be triggered via the mental commands

## Basic Architecture and Breakdown
![Untitled_Artwork (1)](https://github.com/Gupta-Aryaman/smooth-moves/assets/34962578/d620b2c7-7c86-43be-8d02-8bdf729b4996)

Our iOS application, developed in Swift, integrates Shortcuts created in the iOS Shortcuts app with brain triggers detected by our backend system. Swift was chosen for its native compatibility, seamless integration with iOS, and robust performance.

### Backend System:
1. Consists of a Python script interacting with a BCI headset.
2. Detects mental commands and facial expressions in real-time.
3. Sends signals to the Firebase Realtime Database containing information about the detected commands.
   
### Firebase Realtime Database:
1. Acts as a real-time communication bridge between the backend and frontend.
2. Updates corresponding nodes/entries upon receiving signals from the backend.
   
### iOS Application:
1. Constantly listens for changes in the Realtime Database.
2. Retrieves relevant data upon detecting a mental command signal.
3. Initiates the corresponding action or shortcut associated with the detected command.
   
### Example Workflow
1. The user configures a shortcut to open a specific app when they concentrate intensely.
2. The BCI headset detects a high-intensity concentration command.
3. The backend system processes this command and updates the Firebase Realtime Database.
4. The iOS app detects the update, retrieves the shortcut information, and executes the shortcut.
