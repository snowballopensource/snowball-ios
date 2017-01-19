# snowball-ios-old
Snowball for iOS
Open Xcode 7, open cloned project “Snowball.xcworkspace”
Click the project in the project navigator, then select the target Snowball
Ensure the correct team is selected
Bump the build number to whatever the current TestFlight build is + 1


On the top left, to the right of the play button (in screenshot it says iPhone 6s Plus), pick “Generic iOS Device”
In the top bar, select Product > Archive
Once it’s done archiving, it will bring up a list of builds. On the right, click Export -> Save for iOS App Store Deployment -> uncheck the “Include bitcode.” option. Save it wherever when it’s done exporting.
Go to Xcode (most recent) in your Applications, right click, Show Package Contents > Contents/Applications > Application Loader (yes, have to use this, can’t upload builds with old Xcode 7 anymore. See http://stackoverflow.com/q/37838487/801858)
Instructions on uploading with Application Loader here: http://stackoverflow.com/a/40128897/801858
