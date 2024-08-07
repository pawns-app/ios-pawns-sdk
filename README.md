![iOS](https://img.shields.io/badge/iOS-15.0-orange?labelColor=gray&style=flat&logo=swift)
![MacOS](https://img.shields.io/badge/MacOS-13.0-orange?labelColor=gray&style=flat&logo=swift)

# Pawns.app #

  ![alt text](https://pawns.app/wp-content/uploads/2022/12/pawns-app-dark.svg) </br>
  </br> **An internet sharing SDK for iOS & MacOS** </br>
  Contact our representative to get terms and conditions and collect all information needed.

  > [!IMPORTANT]
  > **API key required**: You must have a valid API key to proceed.

  > [!WARNING]
  > This service works only in the foreground as iOS does not support background capabilities for this functionality.

## Installation

You can add Pawns.app to an Xcode project by adding it as a package dependency.

  1. From the **File** menu, select **Add Package Dependencies...**
  2. Enter "https://github.com/pawns-app/ios-pawns-sdk" into the package 
     repository URL text field
  3. Depending on how your project is structured:
      - If you have a single application target that needs access to the library, then add 
        **Pawns.app** directly to your application.
      - If you want to use this library from multiple Xcode targets, or mix Xcode targets and SPM 
        targets, you must create a shared framework that depends on **Pawns.app** and 
        then depend on that framework in all of your targets. For an example of this, check out the 
        [Pawns.app SDK Demo](https://github.com/pawns-app/ios-pawns-sdk-demo) demo application.

## Setup ##

  **SwiftUI**

  Put `Pawns.setup` inside `AppDelegate.application(_:didFinishLaunchingWithOptions:)` method, which is one of the first methods that runs when your app starts. This ensures that the library is properly initialized before any other part of the app tries to use it.

  ```
  import Pawns

  class AppDelegate: NSObject, UIApplicationDelegate {

      func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

          Pawns.setup(apiKey: "api_key")
          
          return true
      }
  }
  ```
  
  In your *YourApp.swift* file add `@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate` without it AppDelegate wont work,.

  ```
  @main
  struct YourApp: App {

      @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
      var body: some Scene {
         ...
      }

  }
  ```

### How to use ####

#### Start ####

Starts Pawns service and returns status updates.

```
Pawns.start()
```

```
for await status in await Pawns.start() {
  ...
}
```

You can run it asynchronously.
```
Task.detached {
  await Pawns.start()
}
```

#### Stop ####

Completely kills the service.

```
Pawns.stop()
```

#### Status ####

Returns the current Pawns status.

```
Pawns.status()
```

#### isRunning ####

Returns a `Bool` value which indicates if the service has been started.

```
Pawns.isRunning()
```

# License #
~~~~
 Copyright 2022 Pawns.app.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
~~~~
