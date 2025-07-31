# Firebase Service Account Setup for Push Notifications

## 🔥 Your Firebase Project Details
- **Project ID**: `secrets-wedding`
- **Auth Domain**: `secrets-wedding.firebaseapp.com`
- **Messaging Sender ID**: `969854232661`
- **App ID**: `1:969854232661:web:0d416ed2d43da2e70e0cdc`

## 🔧 Steps to Get Firebase Service Account Key

### Step 1: Go to Firebase Console
1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **secrets-wedding**

### Step 2: Navigate to Service Accounts
1. Click on **Project Settings** (gear icon)
2. Go to **Service accounts** tab
3. You should see "Firebase Admin SDK" section

### Step 3: Generate Service Account Key
1. Click **"Generate new private key"**
2. Click **"Generate key"** in the confirmation dialog
3. A JSON file will be downloaded (e.g., `secrets-wedding-firebase-adminsdk-xxxxx.json`)

### Step 4: Configure Backend
Choose one of these methods:

#### Method 1: Complete JSON Key (Recommended)
1. Open the downloaded JSON file
2. Copy the entire JSON content
3. Add to your `.env` file:
```bash
FIREBASE_SERVICE_ACCOUNT_KEY='{"type":"service_account","project_id":"secrets-wedding","private_key_id":"...","private_key":"-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n","client_email":"firebase-adminsdk-xxxxx@secrets-wedding.iam.gserviceaccount.com","client_id":"...","auth_uri":"https://accounts.google.com/o/oauth2/auth","token_uri":"https://oauth2.googleapis.com/token","auth_provider_x509_cert_url":"https://www.googleapis.com/oauth2/v1/certs","client_x509_cert_url":"https://www.googleapis.com/robot/v1/metadata/x509/..."}'
```

#### Method 2: Individual Fields
Extract these fields from the JSON and add to `.env`:
```bash
FIREBASE_PROJECT_ID=secrets-wedding
FIREBASE_PRIVATE_KEY_ID=your-private-key-id-from-json
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@secrets-wedding.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=your-client-id-from-json
```

## 🚀 Test the Configuration

### Step 1: Restart Server
```bash
npm start
```

### Step 2: Check Status
```bash
curl http://localhost:3000/api/notifications/status
```

You should see:
```json
{
  "service": "Push Notification API",
  "status": "connected",
  "configured": {
    "firebaseProjectId": true,
    "firebaseServiceAccount": true
  }
}
```

### Step 3: Send Test Notification
```bash
curl -X POST http://localhost:3000/api/notifications/send \
  -H "Content-Type: application/json" \
  -d '{
    "token": "eAxrpmKxSBu5ZctRtEcRpt:APA91bHoIGjjAq0mMOl83bjXq3Qw0T5Pe9pFnVacreW1-dhnbdcB5dXZzFdbSU9uUw_nPfNAFOI2tKUkOtPoMLIraN0Y9jew2jh-cqqs99xvEecakqjbbxY",
    "title": "Real Firebase Test 🔥",
    "body": "This notification is sent via real Firebase!"
  }'
```

## 📱 Mobile App Configuration

Your mobile app needs these configurations:

### Android (`android/app/google-services.json`)
Download from Firebase Console > Project Settings > General > Your apps > Android app

### iOS (`ios/Runner/GoogleService-Info.plist`)
Download from Firebase Console > Project Settings > General > Your apps > iOS app

### Flutter Dependencies
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.10
```

### Initialize Firebase in Flutter
```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
```

## 🔍 Troubleshooting

### Issue: "Firebase not initialized"
- Check if service account key is properly formatted JSON
- Verify all required fields are present
- Restart the server after adding credentials

### Issue: "Invalid token"
- Ensure your mobile app is properly configured with Firebase
- Check that the FCM token is current and valid
- Verify the token is for the correct Firebase project

### Issue: "Permission denied"
- Verify the service account has proper permissions
- Check that Firebase Cloud Messaging is enabled in your project

## 🎯 Expected Results

Once configured correctly:
- ✅ Server logs: "✅ Firebase Admin SDK initialized successfully"
- ✅ Status endpoint shows "connected"
- ✅ Real notifications delivered to your device
- ✅ No more "mock mode" messages

## 🔐 Security Notes

- Never commit service account keys to version control
- Use environment variables for sensitive data
- Restrict service account permissions to minimum required
- Rotate keys periodically for security

---

**Next Step**: Get your Firebase service account key and add it to the `.env` file, then restart the server!
