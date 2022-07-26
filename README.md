# Travel-Diary

[App store](https://apps.apple.com/tw/app/travel-diary/id1630665861)

Travel Diary provides users a platform for planning and recording their  journey
- Imported Drag and Drop API for users to easily arrange their journey
- Implemented MapKit for searching spots and showing travel itinerary
- Automatically generated PDF from user’s journey by using PDFKit
- Implemented QR Code mechanism for sharing and joining the travel groups with AVFoundation
- Implemented app screen and Auto Layout programmatically


<p align="center">
<img src="https://github.com/dolores0105/toPether/blob/main/screenshots/toPetherIconwithName.png" width="160" height="226"/>
</p>

<p align="center">
  <b>toPether</b> provides a place for close members to <b>keep records</b> for the <b>pets that they keep together</b>, <br>they could <b>sync the information</b> about the pet with each other in the pet group.
</p>

<p align="center"><a href="https://apps.apple.com/tw/app/topether/id1591802267">
<img src="https://i.imgur.com/X9tPvTS.png" width="120" height="40"/>
</a></p>


## Features

### Hightlights
- Real-time data synchronization in the pet group 
- Record food/medical information of the pet
- Send messages to members of the pet group for a quick sync
- Take a todo list for a member in the pet groups

### Pet Group
#### Create a pet group
- Create a new pet group by filling in some pet information

<img src="https://github.com/dolores0105/toPether/blob/main/screenshots/CreatePetGroup.png" width="540" height=""/>


#### Invite member/Join into the pet group
- Show QRCode to be scanned

<img src="https://github.com/dolores0105/toPether/blob/main/screenshots/ShowQRCode.png" width="540" height=""/>


- Scan the QRCode of the member to invite him/her to the specific group 

<img src="https://github.com/dolores0105/toPether/blob/main/screenshots/ScanQRCode.png" width="540" height=""/>

### Records
#### Food/Medical records
- Record food/medical notes of the pet with members, and view the history records

<img src="https://github.com/dolores0105/toPether/blob/main/screenshots/TakeRecord.png" width="540" height=""/>


### Messages
- Text a message to the members for the instant information sync

<img src="https://github.com/dolores0105/toPether/blob/main/screenshots/Message.png" width="540" height=""/>

### Todos
- Make a todo list for reminding a member of something that needs to do for the pet

<img src="https://github.com/dolores0105/toPether/blob/main/screenshots/TakeTodo.png" width="540" height=""/>


## Technical Highlights
- Developed readable and maintainable codes in Swift using **OOP** and **MVC** architecture.
- Implemented **Auto Layout programmatically** to make the app compatible with all the iPhones.
- **Customized and reused UI components** to optimize maintainability and brevity of codes.
- Utilized **AVFoundation** for QRCode scanner for inviting members into the pet group with more convenience.
- Implemented **Firestore Snapshot Listener** to perform real-time data synchronization and interactions **across Collections**.
- Completed account system via **Sign in with Apple**, and integrated **Firebase Auth** and **Firestore** database. 
- Applied **User Notifications** for reminding users of their to-do lists.
- Used **Singleton** to access the single instance centralizing data management.
- Transformed image into **Base64 encoded string** to increase uploading efficiency.


## Libraries
- [Firestore](https://firebase.google.com)
- [lottie-ios](https://github.com/airbnb/lottie-ios)
- [IQKeyboardManagerSwift](https://github.com/hackiftekhar/IQKeyboardManager)
- [SwiftLint](https://github.com/realm/SwiftLint)
- [Kingfisher](https://github.com/onevcat/Kingfisher)
- [FloatingPanel](https://github.com/scenee/FloatingPanel)


## Version
1.1.1


## Requirement
- Xcode 13.0 or later
- iOS 15.0 or later


## Release Notes
| Version | Date | Description                                                                                     |
| :-------| :----|:------------------------------------------------------------------------------------------------|
| 1.1.1   | 2022.07.25 | Fix Bug |
| 1.1.0   | 2022.07.16 | Add leave group and copy other's journey mechanism |
| 1.0.1   | 2022.07.14 | Optimize UI |
| 1.0.0   | 2022.07.13 | Launched in App Store |


## Contact

Jackie Huang 黃昱崴
[jackie1wu41@gmail.com](jackie1wu41@gmail.com)

## License

This project is licensed under the terms of the MIT license
