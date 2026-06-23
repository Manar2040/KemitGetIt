# KemitGetIt: Backend Integration & Testing Status Report

This document lists the status of all app features, showing what has been successfully connected to the backend (integrated & tested) and what remains to be connected.

---

## 📊 Summary Statistics

| Section | Fully Integrated & Tested | Semi-Integrated / Mocked | Not Implemented |
| :--- | :---: | :---: | :---: |
| **Authentication & Profile** | 80% | 20% | 0% |
| **Tourist Section** | 75% | 20% | 5% |
| **Guide Section** | 0% | 100% | 0% |

---

## 🔑 1. Authentication & Profile Management

| Feature | Screen / View | ViewModel & Service | Status | Backend Endpoints |
| :--- | :--- | :--- | :---: | :--- |
| **Tourist Registration** | `RegisterScreen` | `AuthViewModel` / `AuthService` | ✅ Integrated | `POST /api/auth/register` |
| **Login** | `LoginScreen` | `AuthViewModel` / `AuthService` | ✅ Integrated | `POST /api/auth/login` |
| **JWT Token Management**| Global | `TokenStorage` / `ApiClient` | ✅ Integrated | Auto-appended to Headers, Global 401 interceptor |
| **Tourist Profile View** | `profile_view.dart` | `TouristProfileViewModel` | ✅ Integrated | `GET /api/users/tourist/profile` |
| **Tourist Profile Edit** | `edit_profile_view.dart` | `TouristProfileViewModel` | ✅ Integrated | `PUT /api/users/tourist/profile` |
| **Guide Profile Verification**| `profile_verification_screen.dart` | *None (Mock Navigation)* | 🚧 Mock UI | Needs endpoint for uploading verification documents and bio. |

---

## 🗺️ 2. Tourist Section

| Feature | Screen / View | ViewModel & Service | Status | Backend Endpoints |
| :--- | :--- | :--- | :---: | :--- |
| **Home (Explore Places)** | `home_view.dart` | `PlacesViewModel` / `PlacesService` | ✅ Integrated | `GET /api/places` |
| **Place Details** | `place_details_view.dart` | `PlacesViewModel` / `PlacesService` | ✅ Integrated | `GET /api/places/{id}` |
| **Wishlist (Favorites)** | `wishlist_view.dart` | `WishlistViewModel` / `PlacesService` | ✅ Integrated | `GET /api/wishlist`, `POST /api/wishlist/{id}` |
| **My Plan (Cart)** | `my_plan_view.dart` | `MyPlanViewModel` / `MyPlanService` | ✅ Integrated | `GET /api/myplan`, `POST /api/myplan/add` |
| **Request Private Guide** | `trip_request_form_view.dart`| `HoldRequestViewModel` / `HoldRequestService` | ✅ Integrated | `POST /api/requests/tourist` |
| **Trip Requests Status Feed**| `my_requests_view.dart` | `HoldRequestViewModel` / `HoldRequestService` | ✅ Integrated | `GET /api/requests/tourist/me` (Tracks active, pending, completed, declined states) |
| **Ready Packages & Trips** | `trip_plans_view.dart` | `TripsViewModel` / `TripsService` | ✅ Integrated | `GET /api/trips`, `GET /api/trips/{id}` |
| **Write & Submit Reviews** | `add_review_bottom_sheet.dart`| `ReviewService` | ✅ Integrated | `POST /api/reviews` (Sends data to backend if booking context is present, falls back to local return if mockup) |
| **Payments Integration** | `payment_view.dart` | *None (Mock UI)* | 🚧 NOT Connected (Mock UI) | Needs Stripe or Paymob integration. |
| **Chat & Messaging** | `chats_list_view.dart` | *None (Mock Data)* | 🚧 NOT Connected (Mock UI) | Needs SignalR hub or HTTP Polling integration. |
| **Live Guide Tracking** | `live_tracking_view.dart` | *None (Mock Map)* | 🚧 NOT Connected (Mock UI) | Map is static; needs websocket/GPS service integration. |
| **Notifications** | `notifications_view.dart` | *None (Mock Data)* | 🚧 NOT Connected (Mock UI) | UI uses dummy data. Backend APIs exist (`GET /api/notifications`, `PUT /api/notifications/{id}/read`, `POST /api/device/register-token` for Firebase push notifications). Needs mobile-side implementation. |
| **Tourist Wallet** | *No Screen* | *None* | 🔴 NOT Implemented (Missing) | Needs UI and endpoints for `/api/wallet`. |

---

## 🧑‍✈️ 3. Guide Section

> [!WARNING]
> The Guide module currently runs entirely on local dummy/mock data. It is ready for backend API integration once the endpoints are set up.

| Feature | Screen / View | Current Data | Status | Required Backend Endpoints |
| :--- | :--- | :--- | :---: | :--- |
| **Active Trips Dashboard**| `home_screen.dart` / `active_trips_list.dart` | Mock data (`active_trip_model.dart`) | 🚧 Mock UI | `GET /api/guide/trips/active` |
| **Manage Hold Requests** | `hold_requests_screen.dart` | Mock data (`hold_request_model.dart`) | 🚧 Mock UI | `GET /api/guide/requests`, `POST /api/guide/requests/{id}/respond` |
| **My Trips History** | `mytrips.dart` | Mock data | 🚧 Mock UI | `GET /api/guide/trips` |

---

## 🎮 4. Unity 3D Integration

* **Pyramids 3D view** (`pyramids_3d_view.dart` / `unity_embed_view.dart`): ✅ **Integrated locally**.
* **Unity Assets**: 🔄 Kept under local `android/unityLibrary` folder and excluded from Git tracking to avoid repository size limits.
