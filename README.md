# Flutter Location Tracker - README

## 🎯 Project Overview
A real-time location tracking app built with Flutter featuring live location updates, address details, location history, and interactive map visualization using Google APIs.

## 🛠️ APIs Used

### 1. Geolocator API
- Fetches real-time GPS coordinates with high accuracy
- Listens to location changes with 10-meter distance filter
- Updates triggered automatically when user moves

### 2. Geocoding API
- Converts latitude/longitude to readable addresses
- Extracts city, state, and postal code from coordinates
- Provides reverse geocoding for all location updates

### 3. Google Maps Flutter API
- Displays interactive map with current location marker
- Shows location history with multiple markers
- Draws polyline path showing user movement trail

## 📱 Features Implemented
✅ Permission handling (granted/denied/permanently denied states)  
✅ Current location display (lat/lng, city, state, pincode, timestamp)  
✅ Real-time location updates on movement  
✅ Location history list with chronological timestamps  
✅ MVVM architecture (Model-View-ViewModel pattern)  
✅ **Bonus:** Interactive map with markers and path visualization  
✅ **Bonus:** Dark/light theme support

## 🏗️ Architecture
**MVVM Pattern** with clean separation:
- **Model:** `LocationModel` - Data structure for location info
- **ViewModel:** `LocationViewModel` - Business logic, permission handling, location updates
- **View:** `LocationScreen`, `MapScreen` - UI components

**State Management:** Provider (ChangeNotifier) for reactive UI updates and in-memory storage.

## 💡 How My Experience Helped

**State Management:** Chose Provider for its simplicity and efficiency. Implemented ChangeNotifier pattern to reactively update UI when location changes, keeping all data in-memory without database complexity.

**Permission Flow:** Designed comprehensive permission handling covering all scenarios (denied, granted, permanently denied) with clear UI feedback and action buttons, ensuring users can always enable location access.

**Real-time Optimization:** Configured location updates with 10m distance filter to balance accuracy and battery life. Used stream-based approach for non-blocking continuous tracking.

**API Integration:** Efficiently integrated Geocoding API with proper async/await handling for smooth address resolution. Implemented error handling with user-friendly messages for network failures or API errors.

**UX Design:** Applied Material Design 3 with consistent spacing and responsive layouts. Added loading indicators, error banners, and empty states for better user experience.

## 🚀 Setup Instructions

1. **Install dependencies:** `flutter pub get`
2. **Get Google Maps API Key:** Enable Maps SDK (Android/iOS) and Geocoding API at [Google Cloud Console](https://console.cloud.google.com/)
3. **Add API Key:**
   - Android: `android/app/src/main/AndroidManifest.xml`
   - iOS: `ios/Runner/AppDelegate.swift`
4. **Add Permissions:**
   - Android: `AndroidManifest.xml` (ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION)
   - iOS: `Info.plist` (NSLocationWhenInUseUsageDescription)
5. **Run:** `flutter run`

## 📦 Key Packages
- `geolocator: ^14.0.2` - Location services
- `geocoding: ^4.0.0` - Address from coordinates
- `google_maps_flutter: ^2.14.0` - Map UI
- `provider: ^6.1.5+1` - State management
- `permission_handler: ^12.0.1` - Permission handling
- `intl: ^0.20.2` - Date formatting

## 🎥 Demo Video
[Watch Demo Video](https://drive.google.com/file/d/1fEiEePjaciEjHu13nlzB3e0RBeYqJzuT/view?usp=sharing)

---
**Tech Stack:** Flutter | Google Maps API | Geocoding API | Provider State Management
