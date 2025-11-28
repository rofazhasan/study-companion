# Study Companion 📚

> **Your Ultimate Zero-Cost, Private, Offline-First Student Companion**

![Banner](https://via.placeholder.com/1200x400?text=Study+Companion+App+Banner)

A comprehensive, open-source Flutter application designed to revolutionize how students focus, plan, and study. Built with privacy and efficiency in mind, Study Companion offers a suite of powerful tools—from AI-powered planning to gamified study sessions—all without requiring expensive subscriptions or constant internet connectivity.

![Version](https://img.shields.io/badge/version-1.0.0--release-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.10.0+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0.0+-0175C2?logo=dart)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Android%20|%20iOS-lightgrey)

---

## 🌟 Why Study Companion?

- **🚫 Zero Distractions**: A dedicated Focus Mode with deep focus capabilities to keep you in the zone.
- **🔒 Privacy First**: Your data lives on your device. No tracking, no selling data.
- **🤖 AI-Powered**: Integrated with Google Gemini for smart scheduling, summarization, and tutoring.
- **🎮 Gamified Learning**: Earn XP, level up, and complete daily missions to make studying fun.
- **⚡ Offline Capable**: Works perfectly without internet (except for AI features).

---

## ✨ Key Features

### 🎯 Deep Focus Mode
- **Pomodoro Timer**: Customizable work/break intervals to prevent burnout.
- **App Blocking**: (Android) Restrict distracting apps during study sessions.
- **Analytics**: Visualize your focus patterns and productivity peaks.

### 📅 Smart Routine Management
- **AI Planner**: Let Google Gemini generate an optimized daily schedule based on your goals.
- **Dynamic Scheduling**: Easily drag-and-drop blocks for Study, Homework, Revision, and more.
- **Mission Sync**: Your daily missions automatically adjust based on your schedule.

### 🧠 Intelligent Learning Tools
- **Notes Scanner**: Instantly convert physical notes to digital text using OCR.
- **AI Tutor**: Chat with an AI assistant to clarify doubts and get explanations.
- **Flashcards**: Create and review flashcards with spaced repetition.
- **Quiz Generator**: Generate quizzes from your notes automatically.

### 📝 Exam Management
- **Exam Planner**: Organize exams with subjects, dates, and durations.
- **PDF Export**: Generate professional exam schedules for printing.
- **Reminders**: Get timely notifications so you never miss a test.

### 📊 Comprehensive Analytics
- **Health Score**: A daily metric showing your routine adherence and balance.
- **Subject Analysis**: Track exactly how much time you spend on each subject.
- **Weekly Reports**: Get insights into your long-term study habits.

---

## 📸 Screenshots

| Home Dashboard | Focus Mode | AI Chat |
|:---:|:---:|:---:|
| ![Home](https://via.placeholder.com/250x500?text=Home) | ![Focus](https://via.placeholder.com/250x500?text=Focus) | ![Chat](https://via.placeholder.com/250x500?text=AI+Chat) |

| Routine Planner | Analytics | Gamification |
|:---:|:---:|:---:|
| ![Routine](https://via.placeholder.com/250x500?text=Routine) | ![Analytics](https://via.placeholder.com/250x500?text=Analytics) | ![Gamification](https://via.placeholder.com/250x500?text=Gamification) |

---

## 🏗️ Tech Stack

This project showcases modern Android development practices using Flutter:

- **Framework**: [Flutter](https://flutter.dev) (3.10+)
- **Language**: [Dart](https://dart.dev)
- **State Management**: [Riverpod](https://riverpod.dev) (v2.6.1) - For robust and testable state management.
- **Local Database**: [Isar](https://isar.dev) (v3.1.0) - High-performance NoSQL database for offline data.
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router) - Declarative routing.
- **AI Integration**: [Google Generative AI SDK](https://pub.dev/packages/google_generative_ai) (Gemini).
- **Authentication**: [Firebase Auth](https://firebase.google.com/docs/auth) - Secure user login.
- **ML & OCR**: [Google ML Kit](https://developers.google.com/ml-kit) - On-device text recognition.
- **Charts**: [FL Chart](https://pub.dev/packages/fl_chart) - Beautiful, animated charts.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.10.0 or higher)
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/rofazhasan/study-companion.git
   cd study-companion
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run Code Generation**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the App**
   ```bash
   flutter run
   ```

### Building for Release
To build the APK for Android:
```bash
flutter build apk --release --no-tree-shake-icons
```
The APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.

---

## 🤝 Contributing

Contributions are welcome! Whether it's reporting a bug, suggesting a feature, or writing code, we value your input.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 👨‍💻 Developer

**Md. Rofaz Hasan Rafiu**

- 🌐 **GitHub**: [@rofazhasan](https://github.com/rofazhasan)
- 💼 **LinkedIn**: [Md. Rofaz Hasan Rafiu](https://www.linkedin.com/in/md-rofaz-hasan-rafiu)
- 📘 **Facebook**: [rofazhasanrafiu](https://www.facebook.com/rofazhasanrafiu/)

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

<div align="center">
  
  **Built with ❤️ for students everywhere**
  
  ⭐ **Star this repo** if you find it helpful!

</div>
