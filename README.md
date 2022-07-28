# Travel-Diary

<p align="center">
<img src="https://i.imgur.com/ClWXVyE.png" width="160" height="160"/>
</p>

<p align="center">
  <b>Travel Diary</b> provides users a platform for planning and recording their journey
</p>

<p align="center"><a href="https://apps.apple.com/tw/app/travel-diary/id1630665861">
<img src="https://i.imgur.com/X9tPvTS.png" width="120" height="40"/>
</a></p>

<p align="center">
	<img src="https://img.shields.io/badge/Swift-5.0-yellow.svg?style=flat">
  <img src="https://img.shields.io/badge/license-MIT-informational">
  <img src="https://img.shields.io/badge/release-v1.1.1-orange">
</p>


## Features

<p align="center">
<img src="https://i.imgur.com/a3SztPV.gif" width="200" height="400"/>
&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
<img src="https://i.imgur.com/vL8THrj.gif" width="200" height="400"/>
</p>

### Hightlights
- Imported Drag and Drop API for users to easily arrange their journey
- Implemented MapKit for searching spots and showing travel itinerary
- Automatically generated PDF from user’s journey by using PDFKit
- Implemented QR Code mechanism for sharing and joining the travel groups with AVFoundation
- Implemented app screen and Auto Layout programmatically

### Plan Journey

#### Arrange a schedule
<p align="center">
<img src="https://i.imgur.com/OpHpfuw.png" width="200" height="400"/>
&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
<img src="https://i.imgur.com/b3pIgL8.png" width="200" height="400"/>
&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
<img src="https://i.imgur.com/IFkTwAi.png" width="200" height="400"/>
</p>

- Add annotations and draw routes with **MapKit**
- Search spots with **MapKit**
- Implement searching feature through **UISearchController**
- Provide easy switching mechanism through **UITableViewDragDelegate**
- Auto saving while leaving page or moving to background
- Link to Maps for navigation

#### Invite member/Join into the travel group
<p align="center">
<img src="https://i.imgur.com/Ie3bChq.png" width="200" height="400"/>
&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
<img src="https://i.imgur.com/DdT5wJ4.png" width="200" height="400"/>
</p>

- Using **CIImage** to generate QR Code
- Using **AVFoundation** to open camera and **CIDetector** to dicipher QR code

#### Edit journey diary
<p align="center">
<img src="https://i.imgur.com/mWpIEeW.png" width="200" height="400"/>
&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
<img src="https://i.imgur.com/lnBcwkN.png" width="200" height="400"/>
&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
<img src="https://i.imgur.com/d1LjZjQ.png" width="200" height="400"/>
</p>

- Add photo from album or camera through **UIImagePicker**
- Provide both simply and complex schdule table

### Share Journey
#### Share journey PDF
<p align="center">
<img src="https://i.imgur.com/UiN0zNC.png" width="200" height="400"/>
</p>

- Automatically generate journey PDF through **PDFKit**

#### Share on community
<p align="center">
<img src="https://i.imgur.com/Nj8iOja.png" width="200" height="400"/>
&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
<img src="https://i.imgur.com/zVzLrgY.png" width="200" height="400"/>
</p>

- Leave comment on others journeys
- Automatically adjust textView constraint through listening to keyboard events
- Block other users
- Report inappropriate journeys

### Sign up
#### Sign in with Apple/Google
<p align="center">
<img src="https://i.imgur.com/nVqo4TU.png" width="200" height="400"/>
</p>

- Video backgorund through AVFoundation
- Provide Apple and Google sign up

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
