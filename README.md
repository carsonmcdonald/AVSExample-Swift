# AVSExample-Swift
This is an [Alexa Voice Service](https://developer.amazon.com/public/solutions/alexa/alexa-voice-service) example using Swift specifically for the Mac but the general concept should work on iOS as well. It requires Swift 2 from XCode 7 or later.

Before getting started make sure you have read [getting started with Alexa Voice Service](https://developer.amazon.com/public/solutions/alexa/alexa-voice-service/getting-started-with-the-alexa-voice-service).

[Carthage](https://github.com/Carthage/Carthage) is used for dependancies. After cloning go into the root directory and run:

```
carthage bootstrap
```

You will need to fill out the following three items found in Config.swift before running:

```
struct LoginWithAmazon {
    static let ClientId = ""
    static let ProductId = ""
    static let DeviceSerialNumber = ""
}
```

If you follow the AVS getting started guide from above then the *ClientId* is set up in the *Select or Create a Security Profile* section, the *ProductId* is called *Device Type ID* and set up in the *Device Type Info* section and the *DeviceSerialNumber* can be anything as long as it is unique for the device type (something like "1000-0000-0000-0000" for example).

Once configured you can run the application and configure the authentication. The configure button will open a Login with Amazon web page that will allow you to authorize the application to use Alexa Voice Service. Once complete there will be a link to take you back to the application where you can use the record button to query Alexa.

## Structure

Authorization is performed using the *Implicit Grant* method described in the [Authorizing Your Alexa-enabled Product from a Website](https://developer.amazon.com/public/solutions/alexa/alexa-voice-service/docs/authorizing-your-alexa-enabled-product-from-a-website) documentation. The application runs a simple web server derived from [GCDWebServer](https://github.com/swisspol/GCDWebServer), see *SimpleWebServer.swift* and *login.html* for more information.

The code for recording the request audio can be found in *SimplePCMRecorder.swift*, it is hard coded to the correct format for AVS. As of now this is the only format that will work with AVS so if you change things in this file be prepared for the processing to potentially fail.

The code for uploading the request audio as well as constructing the proper request can be found in *AVSUploader.swift*.

The code in *ViewController.swift* glues together the authorization, recording and uploading.

## Potential Enhancements

- Save config data to prefs, save auth token info to prefs
- Display auth token expiration time on the screen
- Upload to AVS as recording is in progress
- Add a max length for the recording
- Put in task bar, add a global shortcut key to record
