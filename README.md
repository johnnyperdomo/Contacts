# Contacts

## Preview
![Alt Text](https://media.giphy.com/media/YFFDiuxNrIhJtFk1xr/giphy.gif) ![Alt Text](https://media.giphy.com/media/vx3uxDAKjfNOOUYADy/giphy.gif) ![Alt Text](https://media.giphy.com/media/2SXRj97OfG731xraf0/giphy.gif) 

**Built with**
- Ios 11.0
- Xcode 10.1 

## Features
- **Create, Read, Update, and Delete contacts and contact information with ```Core Data``` *(CRUD)***
- **NSManagedObjects:**
  - ```First Name```  *required*
  - ```Last Name``` *required*
  - ```Date Of Birth``` *required*
  - ```Phone Numbers``` *required*
  - ```Emails``` *required*
  - ```Addresses``` *optional*
  - ```Favorite Contact``` *optional*
  - ```Profile Image``` *optional*
- **Can set profile images for contacts and view them in contacts list**
- **Powerful search functionality lets you search for contacts by first name / last name / or individual characters and highlights letters that match search query**
  > search query = **_Johnny Per_**   
  > ```Johnny Per```domo
- **Table View Index and Sections to organize contacts by Name**
- **Can set 'Favorite' ⭐️ contacts and filter for contacts that are only in your 'Favorites' list.**
- **Can sort contacts *A-Z* by ```First, Last Name``` or ```Last, First Name```**
  ```swift
  case byFirstName 
  case byLastName
  ... 
  
  //.byFirstName 
  ["Johnny Perdomo", "Ross Geller", "Rachel Green", "Joey Tribbiani", "Chandler Bing"] //Array of Names
  ["C": ["Chandler Bing"], "J": ["Joey Tribbiani", "Johnny Perdomo"], "R": ["Rachel Green", "Ross Geller"]] //Index Letters in Section
  
  //.byLastName
  ["Perdomo Johnny", "Geller Ross", "Green Rachel", "Tribbiani Joey ", "Bing Chandler"] //Array of Names
  "B": ["Bing Chandler"], "G": [ "Geller Ross", "Green Rachel"], "P": ["Perdomo Johnny"], "T": ["Tribbiani Joey"]] //Index Letters in Section
  ```
- **Can choose birthdate using ```UIDatePicker```**
- **Fully customizable Bulletin Boards by [alexaubry](https://github.com/alexaubry/BulletinBoard)**
- **Beautiful animations by [airbnb](https://github.com/airbnb/lottie-ios)**
- **Error Validations for Completed Contact Profile, Valid Emails, and Valid Phone Numbers, messages handled using     [SwiftMessages](https://github.com/SwiftKickMobile/SwiftMessages)**
  > func **isEmailValid()** -- func **isPhoneNumberValid()**

- **Convert contact addresses into map Coordinates and get route directions using Apple Maps 🚗**
  ```swift
  let geoCoder = CLGeocoder()
  geoCoder.geocodeAddressString(address) //convert street names into coordinates
  mapItem.openInMaps()
  ```
- **Make a phone call by tapping contact's phone number in profile View 📞**
- **Send email by tapping on contact's email in profile view using ```MFMailComposeViewController``` 📩**
- **Powerful 💯 percent bugless code🐞 by covering various edge cases with Unit Tests**
  ```swift
  let email = "gsdfgfdg5fd1g5f"
  let checker = profile.isEmailValid(email) 
  XCTAssertFalse(checker)
  ```

## Requirements
```swift
import CoreData
import MapKit
import Lottie //animations
import MessageUI
import SwiftMessages //A very flexible message bar for iOS written in Swift.
import BLTNBoard //General-purpose contextual cards for iOS
```

**_Pod Files_**
 > Cocoapods  

```swift
pod 'lottie-ios'
pod 'SwiftMessages'
pod 'BulletinBoard' 
```
[BulletinBoard library by alexaubry](https://github.com/alexaubry/BulletinBoard)  
[SwiftMessages library by SwiftKickMobile](https://github.com/SwiftKickMobile/SwiftMessages)  
[lottie-ios library by airbnb](https://github.com/airbnb/lottie-ios)

## License
Standard MIT [License](https://github.com/johnnyperdomo/Contacts/blob/master/LICENSE)
