# Bitmoji Android Sample App

## Getting Started

### Prerequisites

To build the sample app, you will need [Android Studio 3.0+](https://developer.android.com/studio/index.html).

### Set up

You will also need to create a [Github personal access token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/) with repo permissions. Make sure to add the following to your `~/.gradle/gradle.properties` file (create one if it doesn't exist):

```
githubUsername=<github username>
githubPassword=<personal access token>
```

Add your client id and redirect url in the [AndroidManifest.xml](https://github.com/Snap-Kit/bitmoji-sample/blob/master/android/bitmoji-sample-app/src/main/AndroidManifest.xml) file:
* Add the client id and redirect url in the meta tags [here](https://github.com/Snap-Kit/bitmoji-sample/blob/master/android/bitmoji-sample-app/src/main/AndroidManifest.xml#L16)
* Add the format of your redirect url as data under the `SnapConnectActivity` [here](https://github.com/Snap-Kit/bitmoji-sample/blob/master/android/bitmoji-sample-app/src/main/AndroidManifest.xml#L42)

Import the `build.gradle` file and build away!
