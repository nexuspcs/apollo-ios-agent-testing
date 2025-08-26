# Apollo - HSC Tutoring Marketplace

Apollo is an iOS app that connects Gen Z high school students in NSW with HSC-level tutors. The app provides a fast, Uber-like experience for finding, messaging, and booking tutoring sessions.

## Features

### 🔍 **Tutor Discovery**
- **Map-based search** with suburb filtering
- **Tutor cards** showing name, subjects, hourly rate, delivery mode, and availability
- **Smart filters** by subject, rating, availability, and delivery mode
- **Quick booking** with 30min/1h/2h session options

### 🔐 **Authentication**
- **Students**: Phone verification (SMS), first name, year level
- **Tutors**: Full registration with subjects, education level, and Stripe setup
- **Fast onboarding** - tutors can go live in under 45 seconds

### 💬 **Messaging**
- **In-app chat** with typing indicators and read receipts
- **Auto-booking prompts** to encourage session bookings
- **Real-time messaging** powered by Firebase

### 💳 **Payments**
- **Stripe integration** with 4% platform commission
- **Secure payment processing** for all sessions
- **No payment links or contact info sharing** in messages

### 📊 **Dashboards**
- **Student dashboard**: Upcoming sessions, tutor list
- **Tutor dashboard**: Earnings tracker, client management, availability settings

## Technology Stack

- **iOS**: SwiftUI for modern, responsive UI
- **Authentication**: Firebase Auth with phone verification
- **Backend**: Firebase Firestore for real-time data
- **Payments**: Stripe for secure payment processing
- **Maps**: MapKit for location-based tutor search
- **Package Management**: Swift Package Manager

## Project Structure

```
Sources/Apollo/
├── ApolloApp.swift              # Main app entry point
├── Models.swift                 # Core data models (Subject, enums)
├── UserModels.swift             # User, Student, Tutor models
├── SessionModels.swift          # Session, Message, Payment models
├── AuthenticationViewModel.swift # Auth state management
├── AppViewModel.swift           # App state management
└── Views/
    ├── AuthenticationView.swift # Login and registration
    ├── TutorSearchView.swift    # Map-based tutor search
    ├── TutorDetailView.swift    # Tutor profiles and filters
    ├── BookingView.swift        # Session booking and payment
    └── MainViews.swift          # Dashboard, messaging, profile
```

## Key Requirements Met

✅ **Fast & Clear UI**: Uber-like experience with SwiftUI  
✅ **Map-based Search**: MapKit integration with location filtering  
✅ **Quick Signup**: <45 second tutor onboarding flow  
✅ **HSC Subjects**: Comprehensive NSW HSC subject catalog  
✅ **Phone Verification**: Firebase Auth with SMS codes  
✅ **Stripe Integration**: 4% commission payment processing  
✅ **In-app Messaging**: Firebase-powered real-time chat  
✅ **Session Booking**: 30min/1h/2h duration options  
✅ **Student/Tutor Dashboards**: Earnings tracking and session management  

## Getting Started

1. **Clone the repository**
2. **Open Package.swift** in Xcode or compatible IDE
3. **Configure Firebase**: Add GoogleService-Info.plist
4. **Configure Stripe**: Add publishable key to configuration
5. **Build and run** on iOS 16+ simulator or device

## MVP Scope

This implementation focuses on core functionality for a lean MVP:
- Essential user flows (auth, search, book, message, pay)
- Core data models for students, tutors, and sessions
- Stripe payment integration foundation
- Firebase backend integration
- Clean, fast UI optimized for Gen Z users

Advanced features like AI matching, background checks, and content filtering are intentionally excluded to maintain MVP scope and development speed.