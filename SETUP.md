# Apollo iOS App Setup Instructions

## Overview
Apollo is a tutoring marketplace iOS app built with SwiftUI, connecting Gen Z students in NSW with HSC tutors. This guide will help you set up and run the complete iOS application.

## Prerequisites
- Xcode 15.0 or later
- iOS 16.0+ deployment target
- macOS 13.0+ for development
- Apple Developer account (for device testing)

## Setup Instructions

### 1. Clone and Open Project
```bash
git clone <repository-url>
cd apollo-ios-agent-testing
open Apollo.xcodeproj  # Will be created in step 2
```

### 2. Create Xcode Project
Since this is currently a Swift Package, you'll need to create an iOS app project:

1. Open Xcode
2. Create new iOS App project
3. Name it "Apollo"
4. Use SwiftUI and Swift
5. Copy the source files from `Sources/Apollo/` to your Xcode project

### 3. Install Dependencies

#### Option A: Swift Package Manager (Recommended)
1. In Xcode: File → Add Package Dependencies
2. Add Firebase SDK: `https://github.com/firebase/firebase-ios-sdk`
3. Add Stripe SDK: `https://github.com/stripe/stripe-ios`
4. Select these products:
   - FirebaseAuth
   - FirebaseFirestore
   - FirebaseMessaging
   - StripePaymentSheet
   - StripePayments

#### Option B: Update Package.swift
Uncomment the dependencies in `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.18.0"),
    .package(url: "https://github.com/stripe/stripe-ios", from: "23.18.0"),
]
```

### 4. Firebase Configuration

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create new project named "Apollo"
   - Add iOS app with bundle ID: `com.yourteam.apollo`

2. **Download Configuration**
   - Download `GoogleService-Info.plist`
   - Add to Xcode project root
   - Ensure it's added to target

3. **Enable Services**
   - Authentication → Phone
   - Firestore Database
   - Cloud Messaging

### 5. Stripe Configuration

1. **Create Stripe Account**
   - Sign up at [Stripe Dashboard](https://dashboard.stripe.com)
   - Get publishable key from API keys section

2. **Configure in App**
   ```swift
   // Add to AppDelegate or ApolloApp.swift
   StripeAPI.defaultPublishableKey = "pk_test_your_key_here"
   ```

### 6. iOS Permissions

The app requires these permissions (already configured in Info.plist):
- Location (for finding nearby tutors)
- Camera (for profile photos)
- Photo Library (for profile photos)

### 7. Build and Run

1. Select your target device/simulator
2. Build project (⌘+B)
3. Run project (⌘+R)

## Project Structure

```
Apollo/
├── Models/
│   ├── Models.swift              # Core enums and Subject model
│   ├── UserModels.swift          # User, Student, Tutor models
│   └── SessionModels.swift       # Session, Message, Payment models
├── ViewModels/
│   ├── AuthenticationViewModel.swift
│   └── AppViewModel.swift
├── Views/
│   ├── AuthenticationView.swift
│   ├── TutorSearchView.swift
│   ├── TutorDetailView.swift
│   ├── BookingView.swift
│   └── MainViews.swift
├── Resources/
│   ├── Info.plist
│   └── GoogleService-Info.plist
└── ApolloApp.swift
```

## Key Features Implemented

✅ **Authentication Flow**
- Phone number verification with SMS
- Student/Tutor registration
- User type selection

✅ **Tutor Discovery**
- Map-based search with MapKit
- Filter by subject, rate, availability
- Tutor profile cards

✅ **Booking System**
- Session duration selection (30min/1h/2h)
- Date/time picker
- Payment integration placeholder

✅ **Messaging**
- In-app chat interface
- Conversation management
- Real-time messaging foundation

✅ **Dashboards**
- Student: Sessions, tutors
- Tutor: Earnings, schedule, clients

## Next Steps for Production

1. **Complete Firebase Integration**
   - Implement actual Firestore queries
   - Set up real-time listeners
   - Add user data persistence

2. **Stripe Payment Integration**
   - Connect account setup flow
   - Implement payment processing
   - Add webhook handling

3. **Enhanced Features**
   - Push notifications
   - Real-time location tracking
   - Advanced search filters
   - Review and rating system

4. **Testing & Deployment**
   - Unit tests for business logic
   - UI tests for critical flows
   - App Store submission process

## Environment Configuration

### Development
- Use Firebase emulators
- Stripe test keys
- Debug logging enabled

### Production
- Firebase production project
- Stripe live keys
- Analytics enabled
- Crash reporting

## Troubleshooting

### Common Issues

1. **Build Errors**
   - Ensure all dependencies are properly installed
   - Check iOS deployment target (16.0+)
   - Verify GoogleService-Info.plist is added

2. **Firebase Connection**
   - Verify bundle ID matches Firebase project
   - Check Firebase configuration
   - Ensure internet connectivity

3. **Location Services**
   - Test on physical device for GPS
   - Check location permissions
   - Ensure location usage description is set

### Getting Help

- Check Firebase documentation
- Review Stripe iOS SDK docs
- Apple Developer documentation
- Stack Overflow for specific issues