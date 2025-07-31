# Firebase Push Notification Setup Guide

## 🔥 Firebase Project Setup

### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: `four-secrets-wedding` (or your preferred name)
4. Enable Google Analytics (optional)
5. Click "Create project"

### Step 2: Enable Firebase Cloud Messaging
1. In your Firebase project, go to **Project Settings** (gear icon)
2. Navigate to the **Cloud Messaging** tab
3. Note down your **Server key** and **Sender ID**

### Step 3: Generate Service Account Key
1. In Firebase Console, go to **Project Settings** → **Service accounts**
2. Click **"Generate new private key"**
3. Download the JSON file
4. Keep this file secure - it contains sensitive credentials

## 🔧 Environment Configuration

### Option 1: Using Complete JSON Key (Recommended)
Add to your `.env` file:
```bash
FIREBASE_SERVICE_ACCOUNT_KEY='{"type":"service_account","project_id":"your-project-id","private_key_id":"...","private_key":"-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n","client_email":"firebase-adminsdk-xxxxx@your-project-id.iam.gserviceaccount.com","client_id":"...","auth_uri":"https://accounts.google.com/o/oauth2/auth","token_uri":"https://oauth2.googleapis.com/token","auth_provider_x509_cert_url":"https://www.googleapis.com/oauth2/v1/certs","client_x509_cert_url":"https://www.googleapis.com/robot/v1/metadata/x509/..."}'
```

### Option 2: Using Individual Fields
Add to your `.env` file:
```bash
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY_ID=your-private-key-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project-id.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=your-client-id
```

## 📱 Mobile App Configuration

### Android Setup
1. In Firebase Console, click **"Add app"** → **Android**
2. Enter package name: `com.app.four_secrets_wedding_app`
3. Download `google-services.json`
4. Place it in `android/app/` directory
5. Add Firebase SDK to your `android/app/build.gradle`:
```gradle
dependencies {
    implementation 'com.google.firebase:firebase-messaging:23.4.0'
}
```

### iOS Setup
1. In Firebase Console, click **"Add app"** → **iOS**
2. Enter bundle ID: `com.app.four-secrets-wedding-app`
3. Download `GoogleService-Info.plist`
4. Add it to your iOS project in Xcode
5. Add Firebase SDK to your `ios/Podfile`:
```ruby
pod 'Firebase/Messaging'
```

## 🔔 Flutter Integration

### 1. Add Dependencies
Add to your `pubspec.yaml`:
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.10
```

### 2. Initialize Firebase
```dart
// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
```

### 3. Get Device Token
```dart
class NotificationService {
  static Future<String?> getDeviceToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    print('Device Token: $token');
    return token;
  }
}
```

### 4. Handle Notifications
```dart
class NotificationService {
  static void initialize() {
    // Handle foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground notification: ${message.notification?.title}');
      // Show local notification or update UI
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification tapped: ${message.data}');
      // Navigate based on notification data
      _handleNotificationTap(message);
    });

    // Handle notification when app is terminated
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App opened from notification: ${message.data}');
        _handleNotificationTap(message);
      }
    });
  }

  static void _handleNotificationTap(RemoteMessage message) {
    String action = message.data['action'] ?? '';
    switch (action) {
      case 'open_invitation':
        // Navigate to invitation screen
        break;
      case 'open_tasks':
        // Navigate to tasks screen
        break;
      case 'open_wedding_kit':
        // Navigate to wedding kit screen
        break;
    }
  }
}
```

### 5. Request Permissions (iOS)
```dart
static Future<void> requestPermissions() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');
}
```

## 🧪 Testing Your Setup

### 1. Start the Server
```bash
npm run dev
```

### 2. Check Service Status
```bash
curl http://localhost:3000/api/notifications/status
```

### 3. Run Test Script
```bash
./test-push-notifications.sh
```

### 4. Send Test Notification
```bash
curl -X POST http://localhost:3000/api/notifications/send \
  -H "Content-Type: application/json" \
  -d '{
    "token": "YOUR_DEVICE_TOKEN_HERE",
    "title": "Test Notification",
    "body": "Hello from 4 Secrets Wedding!"
  }'
```

## 🚀 Production Deployment

### DigitalOcean Deployment
1. Upload your service account JSON to the server
2. Set environment variables:
```bash
export FIREBASE_PROJECT_ID="your-project-id"
export FIREBASE_SERVICE_ACCOUNT_KEY='{"type":"service_account",...}'
```

3. Restart your application:
```bash
pm2 restart 4secrets-wedding-email
```

### Security Best Practices
- Never commit service account keys to version control
- Use environment variables for sensitive data
- Restrict Firebase project permissions
- Monitor notification usage and costs
- Implement rate limiting for API endpoints

## 📊 Monitoring & Analytics

### Firebase Console
- Monitor notification delivery rates
- View crash reports and performance metrics
- Analyze user engagement with notifications

### API Monitoring
- Check `/api/notifications/status` for service health
- Monitor `/api/notifications/sent` for delivery statistics
- Set up alerts for failed notifications

## 🔧 Troubleshooting

### Common Issues

1. **"Firebase not initialized" Error**
   - Check your service account credentials
   - Verify environment variables are set correctly
   - Ensure Firebase project ID is correct

2. **Notifications Not Received**
   - Verify device token is valid and current
   - Check app is properly configured with Firebase
   - Ensure notification permissions are granted

3. **Invalid Token Errors**
   - Device tokens expire and need to be refreshed
   - Implement token refresh logic in your app
   - Handle token registration errors gracefully

4. **Mock Service Mode**
   - Service falls back to mock mode when Firebase is not configured
   - Check console logs for configuration issues
   - Verify all required environment variables are set

### Debug Commands
```bash
# Check service status
curl http://localhost:3000/api/notifications/status

# Test connection
curl http://localhost:3000/api/notifications/test

# View sent notifications
curl http://localhost:3000/api/notifications/sent
```

## 📚 Additional Resources

- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Firebase Messaging Plugin](https://pub.dev/packages/firebase_messaging)
- [Firebase Console](https://console.firebase.google.com/)
- [FCM HTTP v1 API Reference](https://firebase.google.com/docs/reference/fcm/rest/v1/projects.messages)

---

🎉 **Your Firebase Push Notification service is now ready for the 4 Secrets Wedding app!**
