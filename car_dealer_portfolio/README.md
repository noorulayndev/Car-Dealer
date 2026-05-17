# Car Dealer Mobile Portfolio

**COMP5450 - Mobile Application Development**
**Challenge 2 Submission - Group 4**
**Lakehead University**

## Project Overview

The Car Dealer Mobile Portfolio is a premium Flutter application designed to showcase luxury automotive inventory with real-time customer lead management. This sophisticated mobile showroom provides an immersive browsing experience featuring high-end vehicles from brands like Tesla, BMW, Porsche, Mercedes-Benz, Audi, and Lamborghini. The application combines elegant UI design with robust Firebase integration to deliver a professional-grade automotive retail platform.

### Key Features

- **Dynamic Inventory Management**: Real-time vehicle catalog powered by Cloud Firestore
- **Interactive Filtering**: Category-based filtering by fuel type (Electric, Hybrid, Gas)
- **Immersive Detail Views**: Premium vehicle showcases with comprehensive specifications
- **Professional Lead Capture**: Real-time inquiry submission with form validation
- **Responsive Design**: Optimized for both mobile phones and tablets
- **Clean Architecture**: Modular codebase following Flutter best practices

## Architecture & Ecosystem

### Project Structure

```
lib/
├── main.dart                           # Application entry point with Firebase initialization
├── models/
│   └── car_model.dart                  # Car data model with Firestore integration
├── screens/
│   ├── showroom_screen.dart            # Main inventory grid with filtering
│   └── car_detail_screen.dart          # Premium vehicle detail view
├── services/
│   └── firebase_service.dart           # Cloud Firestore operations & lead management
└── widgets/
    ├── car_card.dart                   # Individual vehicle showcase card
    └── inquiry_bottom_sheet.dart       # Interactive customer inquiry form

pubspec.yaml                            # Dependencies and project configuration
android/                                # Android platform configuration
ios/                                    # iOS platform configuration
```

### Technology Stack

- **Frontend Framework**: Flutter (Dart)
- **Database**: Cloud Firestore (NoSQL real-time database)
- **Authentication**: Firebase Core
- **Typography**: Google Fonts
- **State Management**: StatefulWidget with Form validation
- **Navigation**: Flutter Material Navigation

### Firebase Integration

The application leverages Cloud Firestore for:
- **Dynamic Inventory**: Real-time vehicle data synchronization
- **Lead Management**: Customer inquiry capture in 'leads' collection
- **Data Seeding**: Automated premium vehicle inventory population
- **Server Timestamps**: Precise lead tracking and CRM integration

## Setup & Execution Instructions

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code
- Firebase Project with Firestore enabled

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone [YOUR-REPOSITORY-URL]
   cd car_dealer_portfolio
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   ```bash
   flutterfire configure
   ```

4. **Launch the application**
   ```bash
   flutter run
   ```

### Build for Release

```bash
# Android APK
flutter build apk --release

# iOS (requires macOS and Xcode)
flutter build ios --release
```

## GitHub Public Repository Link

**GitHub Public Repository Link: [INSERT YOUR LIVE URL HERE]**

*Note: Ensure your repository is public and contains all source code, documentation, and configuration files required for complete project evaluation.*

## Application Screenshots

### Main Showroom Grid View
*Insert screenshot showing the premium vehicle inventory grid with filter chips for All, Electric, Hybrid, and Gas categories.*

### Premium Vehicle Detail View
*Insert screenshot displaying the immersive car detail screen with hero image, specifications, features, and dealer profile card.*

### Active Inquiry Bottom Sheet
*Insert screenshot of the interactive customer inquiry form with validation fields for name, email, and message.*

## Technical Implementation Details

### Data Models

The application uses a comprehensive `Car` model with the following structure:
- Vehicle identification and branding information
- Pricing and mileage specifications
- Fuel type classification for filtering
- Premium feature arrays for detailed showcasing
- Network image paths for visual presentation

### Real-time Features

- **Live Inventory Updates**: Firestore listeners ensure inventory changes reflect immediately
- **Instant Lead Capture**: Customer inquiries are submitted to Firebase in real-time
- **Dynamic Filtering**: Immediate UI updates based on fuel type selection
- **Form Validation**: Real-time input validation with professional error messaging

### UI/UX Design Principles

- **Material Design**: Following Google's Material Design guidelines
- **Premium Aesthetics**: Gradient backgrounds, elegant typography, and professional spacing
- **Responsive Layout**: Adaptive grid systems for various screen sizes
- **Accessibility**: Proper contrast ratios and semantic navigation

## Development Team

**Group 4 - COMP5450**
Lakehead University

## License

This project is developed for educational purposes as part of COMP5450 coursework at Lakehead University.
