# Firebase Setup Guide for Sleep Prediction App

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter "Sleep Prediction" as the project name
4. Accept the Firebase terms
5. Choose whether to enable Google Analytics (recommended)
6. Click "Create project" and wait for it to complete

## Step 2: Register Your Android App

1. On the project overview page, click the Android icon (</>) to add an Android app
2. Enter your package name: `com.sleepmodel.sleep_prediction`
3. Enter a nickname (optional, e.g., "Sleep Prediction App")
4. Enter debug signing certificate SHA-1 (optional for now, required for Google Sign-in)
   - To get your SHA-1, run: `cd android && ./gradlew signingReport`
5. Click "Register app"

## Step 3: Download Configuration File

1. Download the `google-services.json` file
2. Place it in the `android/app/` directory of your Flutter project

## Step 4: Enable Authentication

1. In Firebase Console, go to "Build → Authentication"
2. Click "Get started"
3. Enable "Email/Password" provider by clicking on it
4. Toggle the "Enable" switch to on
5. Click "Save"

## Step 5: Set Up Firestore Database

1. Go to "Build → Firestore Database"
2. Click "Create database"
3. Choose "Start in production mode" 
4. Select a location closest to your users
5. Wait for database to be created
6. Go to "Rules" tab
7. Copy the contents from your local `firestore.rules` file
8. Click "Publish"

## Step 6: Configure Firebase Options

1. Fill in your specific Firebase configuration values in `lib/firebase_options.dart`:
   - Find these values in the Firebase console under Project settings → Your apps
   - Replace all placeholders like `REPLACE_WITH_YOUR_API_KEY` with actual values

## Step 7: Test Authentication

After completing the setup:

1. Run your app in debug mode
2. Try to register a new user
3. Check Firebase Authentication console to see if the user was created
4. Try to log in with the created user

## Troubleshooting

If you encounter issues:

- Make sure `google-services.json` is in the correct location
- Make sure the values in `firebase_options.dart` are correct
- Check that you've enabled Email/Password authentication
- Verify your app's package name matches what you registered in Firebase

## Additional Resources

- [FlutterFire Documentation](https://firebase.flutter.dev/docs/overview/)
- [Firebase Authentication Documentation](https://firebase.google.com/docs/auth)
- [Firestore Documentation](https://firebase.google.com/docs/firestore) 