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

Smooth Moves is a pioneering project combining neuroscience and automation to create an inclusive interface for controlling digital tasks using EEG (Electroencephalography) headsets. Through the integration of an Emotiv EPOC X EEG headset, this project enables users to trigger automated actions on their iOS devices via mental commands and facial expressions, making it especially valuable for individuals with limited mobility.

## Demo
![unnamed](https://github.com/Gupta-Aryaman/smooth-moves/assets/34962578/1c721bc7-f2c9-4984-9e52-1c55cd010e97) <br>
Verbose Demo: [Demo Link](https://x.com/aryamantwts/status/1803506381028278419) <br>
Endless possibilites: [Game Control Demo Link](https://x.com/aryamantwts/status/1803510379454275623)

## Key Features
- **Automation with EEG Commands**: Trigger iOS shortcuts via mental commands using the Emotiv EPOC X headset.
- **Accessible Interface**: Designed with a focus on inclusivity, especially for users with physical disabilities.
- **Real-time Execution**: Low-latency communication ensures quick responses to mental triggers.
- **Modular Architecture**: Allows potential expansion to other applications (e.g., gaming, painting).

## Project Components
1. **Emotiv EPOC X EEG Headset** - Captures brainwave data and sends it to the Emotiv WSS server.
2. **Python Backend** - Connects with the Emotiv server, processes commands, and updates Firebase.
3. **Firebase Realtime Database** - Stores and synchronizes data across clients, tracking command triggers in real-time.
4. **Swift iOS Application** - Manages automation commands, integrates with the iOS Shortcuts app, and executes mapped commands.

## Basic Architecture and Breakdown
![Untitled_Artwork (1)](https://github.com/Gupta-Aryaman/smooth-moves/assets/34962578/d620b2c7-7c86-43be-8d02-8bdf729b4996)

Our iOS application, developed in Swift, integrates Shortcuts created in the iOS Shortcuts app with brain triggers detected by our backend system. Swift was chosen for its native compatibility, seamless integration with iOS, and robust performance.

#### Backend System:
* Consists of a Python script interacting with a BCI headset.
* Detects mental commands and facial expressions in real-time.
* Sends signals to the Firebase Realtime Database containing information about the detected commands.
   
#### Firebase Realtime Database:
* Acts as a real-time communication bridge between the backend and frontend.
* Updates corresponding nodes/entries upon receiving signals from the backend.
   
#### iOS Application:
* Constantly listens for changes in the Realtime Database.
* Retrieves relevant data upon detecting a mental command signal.
* Initiates the corresponding action or shortcut associated with the detected command.


## Prerequisites

Ensure you have the following installed:
- **Python 3.8+** and necessary libraries (see `requirements.txt`)
- **Xcode** with Swift support for iOS development
- **Firebase Account** for Realtime Database setup
- **Emotiv EPOC X EEG Headset** and access to Emotiv’s WSS server API
- **iOS device** with the Shortcuts app installed

## Installation and Setup

### 1. Clone the Repository
```bash
git clone https://github.com/Gupta-Aryaman/smooth-moves.git
cd smooth-moves
```

### 2. Python Backend Setup
- Install dependencies:
  ```bash
  pip install -r requirements.txt
  ```
- Set up your `.env` file with Emotiv and Firebase credentials:
  ```
  clientId=YOUR_EMOTIV_CLIENT_ID
  clientSecret=YOUR_EMOTIV_CLIENT_SECRET
  firebaseDatabaseUrl=YOUR_FIREBASE_DATABASE_URL
  ```

### 3. Firebase Realtime Database Configuration
- In your Firebase project, create a Realtime Database.
- Add appropriate permissions and data structure as per the project’s requirements.
- Update the Firebase Realtime Database URL in the `.env` file.
- This is how the realtime database entries look like - <br>
![image](https://github.com/user-attachments/assets/bf3a3e74-ce10-4d85-b141-ff30db70c268)


### 4. Emotiv Headset Setup
- Connect the Emotiv EPOC X headset and configure it with Emotiv’s BCI software.
- Ensure the headset is connected to Emotiv’s WSS server, allowing data to be streamed to the Python backend.

### 5. Swift iOS Application Setup
- Open the `SmoothMovesApp.xcodeproj` file in Xcode.
- Configure Firebase integration in the app for real-time updates.
- Run the app on an iOS device with the Shortcuts app installed.

- This is how my Shortcut to export the list of all Shortcuts looks like. It stores the data in a Persistant Cloud DB and that data is then fetched inside the app. <br>
![png](https://github.com/user-attachments/assets/8de24e8c-f858-43e4-8880-7eaa76a0c6a3)

## Usage

1. **Train Mental Commands**: Configure the EEG headset with mental commands like “push” or “pull” for smooth functioning.
2. **Map Commands to Shortcuts**: Within the iOS app, select a mental command and map it to a shortcut in the Shortcuts app.
3. **Execute Commands**: The backend detects mental commands and updates Firebase, which in turn triggers the corresponding iOS shortcut.

## Example Workflow
1. The user configures a shortcut to open a specific app when they concentrate intensely.
2. The BCI headset detects a high-intensity concentration command.
3. The backend system processes this command and updates the Firebase Realtime Database.
4. The iOS app detects the update, retrieves the shortcut information, and executes the shortcut.

## Testing and Results
![image](https://github.com/user-attachments/assets/7507e244-46cc-4ad0-8a18-36eebd106447) <br>
Testing revealed response times vary by command type and user configuration. Mental commands may require longer to detect than facial expressions but have lower false positive rates.

## Future Enhancements
Potential future improvements include:
- Generalizing the backend for use in multiple applications (e.g., gaming).
- Expanding functionality to include features like direct BCI-to-text input, painting, or complex automation tasks.
