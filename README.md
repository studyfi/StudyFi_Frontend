# 📘 StudyFi Frontend

## 📌 Table of Contents
1. 📖 Introduction  
2. 🛠️ Technology Stack  
3. 🧱 Architecture Overview  
4. 🗂️ Folder Structure  
5. 📱 UI Pages and Workflows  
   - 🔐 Login  
   - 📝 Signup  
   - 🏠 Home  
   - 👥 Groups  
   - 📚 Group Detail  
   - 🔔 Notifications  
   - 🙍‍♀️ Profile  
6. 🌐 API Integration  
7. 💾 State Management and Session Handling  
8. 🛡️ Validation and Error Handling  
9. 🧪 Setup Instructions  
10. 🔗 Useful Links

---

## 🧠 Introduction

**StudyFi** is a cross-platform academic collaboration app built with **Flutter**. It enables students to create or join study groups, share academic materials, post updates, and receive notifications. The frontend communicates with a robust Spring Boot microservice backend.

---

## 🛠️ Technology Stack

| Layer             | Technology        |
|------------------|-------------------|
| UI Framework     | Flutter           |
| Programming Lang | Dart              |
| State Persistence| SharedPreferences |
| HTTP Requests    | http package      |
| Image Upload     | Cloudinary (via backend) |
| Platform Support | Android, iOS, Web |

---

## 🧱 Architecture Overview

- **Flutter App** → sends API requests to **API Gateway** (Spring Cloud Gateway)
- API Gateway routes requests to services:
  - `User & Group Service` (Authentication, Profile, Group)
  - `Content & News Service` (Files, Posts, News)
  - `Notification Service` (Alerts)
- Response → processed in Flutter and stored (e.g., SharedPreferences)

---
## 📁 Folder Structure

```plaintext
lib/
├── components/       # Reusable widgets (buttons, text fields, etc.)
├── models/           # Data models (User, Group, Post, etc.)
├── screens/          # UI pages (Login, Signup, Home, etc.)
├── services/         # API communication (ApiService)
├── constants.dart    # Colors, fonts, sizes
└── main.dart         # App entry point and route management
```


---

## 📱 UI Pages and Workflows

### 🔐 1. Login Page
- **Purpose**: Authenticate users using email and password.
- **Components**:
  - Email/Password fields
  - Login button
  - Links: Signup, Forgot password
- **Features**:
  - Input validation
  - API POST to `/users/login`
  - Store user session (SharedPreferences)
  - Redirect to HomePage

### 📝 2. Signup Page
- **Purpose**: Register new users with personal and academic info.
- **Fields**: name, email, password, DOB, phone, address, country, AboutMe, profile & cover images
- **Flow**:
  - Validates form
  - Submits multipart request to `/users/register`
  - Uploads files to Cloudinary (via backend)
  - Redirects to login page on success

### 🏠 3. Home Page
- **Purpose**: Acts as a navigation hub using a bottom navigation bar.
- **Tabs**: Home, Groups, Notifications, Profile
- **Behavior**:
  - Displays default home view
  - Navigates using `Navigator` or `PageController`

### 👥 4. Groups Page
- **Purpose**: List all groups joined by the user.
- **Features**:
  - Fetches `/groups/user/{userId}`
  - Displays cards with image, name, description
  - Search bar for filtering groups
  - Clickable cards open Group Detail Page

### 📚 5. Group Detail Page
- **Tabs**: Contents, Posts, Members, News
- **Features**:
  - **Contents**: Upload/download academic files (PDF, DOCX, etc.)
  - **Posts**: View/create posts, like, comment
  - **News**: Post updates, view group activities
  - **Members**: View group members
  - **Edit Group**: If admin, update group info
- **APIs Used**:
  - `/content/upload`, `/news/post`, `/chats/groups/{groupId}/posts`, etc.

### 🔔 6. Notifications Page
- **Purpose**: Show user-specific notifications
- **Features**:
  - Fetch from `/notifications/getnotifications/{userId}`
  - Supports marking as read
  - Clickable for redirection to target (group/post)

### 🙍‍♀️ 7. Profile Page
- **Purpose**: View and update user profile
- **Features**:
  - Display profile info + images
  - Edit functionality with API: `/users/profile/{userId}`
  - Images uploaded to Cloudinary

---

## 🌐 API Integration

### ApiService Handles:
- **Authentication**:
  - `POST /users/login`
  - `POST /users/register`
- **Profile**:
  - `GET /users/{id}`
  - `PUT /users/profile/{id}`
- **Groups**:
  - `GET /groups/user/{id}`
  - `POST /groups/create`
- **Content**:
  - `POST /content/upload`
  - `GET /content/group/{groupId}`
- **Posts & Comments**:
  - `POST /chats/groups/{groupId}/posts`
  - `POST /chats/posts/{postId}/comments`
- **Notifications**:
  - `GET /notifications/getnotifications/{userId}`

---

## 💾 State Management and Session Handling

- User data is saved locally using `SharedPreferences`
- Keys like `userId`, `email`, `token` (if any) are persisted
- Session persists across app restarts unless explicitly logged out

---

## 🛡️ Validation and Error Handling

- **Input validation**: email format, required fields, password strength
- **Error messages**:
  - Invalid login: `"Incorrect email or password"`
  - Server error: `"Please check your connection"`
- **Fallbacks**:
  - Default images for null profile/group images
  - Try-catch blocks on network calls

---

## 🧪 Setup Instructions

### 🔧 Requirements
- Flutter SDK (3.x)
- Dart SDK
- Android Studio or VS Code

### 🚀 How to Run
```bash
git clone https://github.com/studyfi/StudyFi_Frontend.git
cd StudyFi_Frontend
flutter pub get
flutter run

## 🔗 Useful Links

- [GitHub Frontend](https://github.com/studyfi/StudyFi_Frontend)  
- [GitHub Backend](https://github.com/studyfi/StudyFi-Backend)  
- [YouTube Demo](https://youtu.be/6EWDbcS4pzE)

