<a name="readme-top"></a>

# 🚘 Car IQ

## 🔎 Description

Car IQ is an iOS application that leverages deep learning and computer vision to detect and recognize cars from images. The user can take a picture of a car or upload one from their gallery, and the app will identify key attributes such as:

- 🚗 Make
- 🏷️ Model
- 🕓 Generation and Year Range
- ✅ Confidence Score

## 🚀 Built With

<p align="center">
  <img src="https://img.shields.io/badge/swift-orange?style=for-the-badge&logo=swift&logoColor=white" />
  <img src="https://img.shields.io/badge/swiftui-1E90FF?style=for-the-badge&logo=swift&logoColor=white" />
  <img src="https://img.shields.io/badge/UIKit-black?style=for-the-badge&logo=apple&logoColor=white" />
  <img src="https://img.shields.io/badge/firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/CarNET%20API-blue?style=for-the-badge" />
</p>

---

## 📱 Features

- 📸 **Snap or Upload Car Photo**: Users can take a picture or upload an image of any car.
- 🔍 **Car Recognition (Deep Learning and Computer Vision)**: CarNET API is used to return:
  - Car **make**
  - Car **model**
  - Car **generation**
  - Approximate **production years**
  - **Confidence score**
- 🛒 **Smart Marketplace Integration**: After identifying a car, users can browse similar cars for sale in their area with one tap.
- 🗃️ **Feed-Style Listings UI**: Car listings are shown in a sleek, scrollable feed layout, allowing users to browse previously scanned or saved vehicles effortlessly.
- 👤 **User Authentication**: Secure login and account management using Firebase Auth.
- ☁️ **Cloud Storage**: Stores uploaded photos and metadata in Firebase.
- 📅 **Timestamping**: Each entry is timestamped for record-keeping.

---
## Video Demo
[![Watch the full video demo here](https://img.youtube.com/vi/lxtj0gMUb-Y/0.jpg)](https://youtube.com/shorts/lxtj0gMUb-Y?feature=share)

---

## 🧰 Getting Started

To run this app locally:

### Prerequisites

- macOS with **Xcode** installed
- Firebase project with Auth and Firestore
- CarNET API credentials

### Setup

1. Clone the repository

```bash
git clone https://github.com/mingleg7756/cardentification.git
cd cardentification
```

2. Open the project in Xcode

```bash
open cardentification.xcodeproj
```

3. Replace the `GoogleService-Info.plist` file with your Firebase config

4. Update your own `Config.xconfig` with the necessary API keys or variables

5. Build and run on a real device or simulator

---

## 👥 Team

### Team Members

- Ming
- Anthony
- Anas
- Ye Htut
- Robert Neagu (Project Presenter)

<p align="right"><a href="#readme-top">Back to top</a></p>
