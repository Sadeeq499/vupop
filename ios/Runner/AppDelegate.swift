import UIKit
import Flutter
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FBSDKCoreKit
import GoogleMaps
import AVFoundation
import Photos

@main
@objc class AppDelegate: FlutterAppDelegate,MessagingDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyAkQBrEp2ZO-gtDnNRGaYOOV5ziXxPKOJ0")
    FirebaseApp.configure()
    Messaging.messaging().delegate = self
    GeneratedPluginRegistrant.register(with: self)
      // Set up a FlutterMethodChannel for communicating with the Flutter side
      let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
      let channel = FlutterMethodChannel(name: "com.vupop.permission",
                                         binaryMessenger: controller.binaryMessenger)
      
      // Define a method call handler for the channel
      channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
          if call.method == "requestPermissions" {
              // Call the function to request permissions
              self.requestPermissions(result: result)
          } else {
              // Return "not implemented" if the method is not recognized
              result(FlutterMethodNotImplemented)
          }
      }
      //Notifications
                if #available(iOS 10.0, *) {
                    // For iOS 10 display notification (sent via APNS)
                    UNUserNotificationCenter.current().delegate = self
                    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                    UNUserNotificationCenter.current().requestAuthorization(
                            options: authOptions,
                            completionHandler: {_, _ in })
                } else {
                    let settings: UIUserNotificationSettings =
                    UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                    application.registerUserNotificationSettings(settings)
                }
                application.registerForRemoteNotifications()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    return ApplicationDelegate.shared.application(app, open: url, options: options)
  }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken ?? "")")
    }
    
    // Function to request photo library permission
    private func requestPermissions(result: @escaping FlutterResult) {
       // Check photo library authorization status
       let photoStatus = PHPhotoLibrary.authorizationStatus()
       let microphoneStatus = AVAudioSession.sharedInstance().recordPermission
       
       var permissionsToRequest = false

       // Request Photo Library Permission if not determined
       if photoStatus == .notDetermined {
           permissionsToRequest = true
           PHPhotoLibrary.requestAuthorization { status in
               if status == .authorized {
                   print("Photo library permission granted")
               } else {
                   print("Photo library permission denied")
               }
           }
       }

       // Request Microphone Permission if not determined
       if microphoneStatus == .undetermined {
           permissionsToRequest = true
           AVAudioSession.sharedInstance().requestRecordPermission { granted in
               if granted {
                   print("Microphone permission granted")
               } else {
                   print("Microphone permission denied")
               }
           }
       }

       if !permissionsToRequest {
           if photoStatus == .authorized && microphoneStatus == .granted {
               result("granted")
           } else {
               result("denied")
           }
       }
    }
}
