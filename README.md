# Study Companion 📚

> **Zero-Cost, Private, Offline-First Student Companion**

A comprehensive Flutter-based application designed to help students focus, study efficiently, plan their day, and stay motivated—all without requiring expensive subscriptions or constant internet connectivity.

![Version](https://img.shields.io/badge/version-0.1.0--beta-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.5.0+-02569B?logo=flutter)
![License](https://img.shields.io/badge/license-MIT-green)

---

## ✨ Features

### 🎯 Focus Mode
- **Pomodoro Timer**: Customizable work/break intervals
- **Session Tracking**: Automatic logging of study sessions
- **Analytics Dashboard**: Visualize your productivity patterns
- **Distraction-Free Environment**: Dedicated focus interface

### 📅 Daily Routine Management
- **AI-Powered Day Planner**: Intelligent schedule generation using Google Gemini
- **Smart Scheduling**: Automatic time blocking for tasks
- **Routine Blocks**: Support for Study, Homework, Revision, Breaks, and Personal time
- **Completion Tracking**: Mark tasks as complete and track progress

### 📝 Exam Routine System
- **Multi-Subject Exams**: Organize exams with multiple subjects
- **Date & Time Management**: Schedule each subject with duration
- **Status Indicators**: Visual cues for upcoming and completed exams
- **Smart Filtering**: View by All, Today, or This Month
- **PDF Export**: Professional exam schedules with formal formatting
- **Notifications**: 24-hour advance reminders for upcoming exams

### 🎮 Gamification & Motivation
- **XP System**: Earn experience points for completed activities
- **Level Progression**: Unlock new levels as you study
- **Daily Missions**: Complete challenges for bonus XP
- **Streak Tracking**: Maintain study consistency
- **Motivational Quotes**: Regular inspiration to stay focused

### 📊 Analytics & Insights
- **Study Time Tracking**: Detailed breakdowns by subject and type
- **Performance Graphs**: Visual representations using FL Chart
- **Health Score**: Daily wellness metrics based on routine adherence
- **Weekly Reports**: Comprehensive performance summaries
- **Subject-wise Analysis**: Track time spent on each subject

### 🤖 AI Features (Powered by Google Gemini)
- **AI Day Planner**: Automatically generate optimized daily schedules
- **Smart Suggestions**: Context-aware study recommendations
- **Evening Reflection**: Guided end-of-day review prompts
- **Flexible Configuration**: Use your own Gemini API key

### ☁️ Cloud Sync (Optional)
- **Supabase Integration**: Backup your data to the cloud
- **Privacy-First**: Completely optional—works 100% offline
- **Cross-Device Sync**: Access your data from multiple devices
- **Secure Authentication**: Firebase Auth with email verification

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: Version 3.5.0 or higher
- **Android Studio** or **VS Code** with Flutter extensions
- **Google Gemini API Key** (for AI features)
- **Git**: For version control

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/rofazhasan/study-companion.git
   cd study-companion
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate code** (for Isar, Riverpod):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Configure API Keys** (Optional for AI features):
   - Get a Gemini API key from [Google AI Studio](https://aistudio.google.com/app/apikey)
   - The app will prompt for the key on first use of AI features

5. **Run the app**:
   ```bash
   flutter run
   ```

---

## 🏗️ Architecture

### Tech Stack

- **Framework**: Flutter 3.5.0+
- **Language**: Dart
- **State Management**: Riverpod (v2.6.1)
- **Local Database**: Isar (v3.1.0) - Fast NoSQL database
- **Navigation**: GoRouter (v14.6.0)
- **AI Integration**: Google Generative AI (Gemini)
- **Backend (Optional)**: Supabase
- **Authentication**: Firebase Auth
- **PDF Generation**: pdf (v3.11.3) + printing (v5.14.2)
- **Charts**: FL Chart (v1.1.1)
- **Notifications**: flutter_local_notifications (v19.5.0)

### Project Structure

```
lib/
├── core/                      # Core utilities and services
│   ├── data/                  # Isar service, connectivity
│   ├── providers/             # Global providers (theme, etc.)
│   └── services/              # Notification service
├── features/                  # Feature modules
│   ├── ai_chat/              # AI-powered features
│   ├── analytics/            # Study analytics
│   ├── auth/                 # Authentication
│   ├── focus_mode/           # Pomodoro timer
│   ├── gamification/         # XP, levels, missions
│   ├── onboarding/           # User onboarding
│   ├── routine/              # Daily routine & exams
│   └── settings/             # App settings
└── main.dart                 # App entry point
```

---

## 📱 Building

### Debug Build
```bash
flutter build apk --debug
```

### Release Build
```bash
flutter build apk --release --no-tree-shake-icons
```

The APK will be generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔒 Privacy & Security

- **Local-First**: All data stored locally on your device using Isar
- **No Tracking**: No analytics or telemetry collected
- **Optional Cloud**: Sync is completely opt-in
- **Secure Keys**: API keys are user-provided, never hardcoded
- **Open Source**: Full source code available for audit

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Commit your changes**: `git commit -m 'Add amazing feature'`
4. **Push to the branch**: `git push origin feature/amazing-feature`
5. **Open a Pull Request**

### Development Guidelines

- Follow Flutter/Dart style guidelines
- Write clean, documented code
- Test your changes thoroughly
- Update documentation as needed

---

## 📝 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Developer

**Md. Rofaz Hasan Rafiu**

- 🌐 **GitHub**: [@rofazhasan](https://github.com/rofazhasan)
- 💼 **LinkedIn**: [Md. Rofaz Hasan Rafiu](https://www.linkedin.com/in/md-rofaz-hasan-rafiu)
- 📘 **Facebook**: [rofazhasanrafiu](https://www.facebook.com/rofazhasanrafiu/)

---

## 🙏 Acknowledgements

- **Google Gemini AI** - Powering intelligent features
- **Flutter Team** - For the amazing cross-platform framework
- **Open Source Community** - For all the incredible packages used in this project
- **Students Worldwide** - The inspiration behind this app

---

## 📧 Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/rofazhasan/study-companion/issues) page
2. Create a new issue with detailed information
3. Contact the developer via social media links above

---

## 🗺️ Roadmap

### Upcoming Features
- [ ] Desktop support (Windows, macOS, Linux)
- [ ] iOS version
- [ ] Collaborative study groups
- [ ] Advanced AI tutoring
- [ ] More export formats (Excel, CSV)
- [ ] Custom themes
- [ ] Widget support

---

<div align="center">

**Built with ❤️ for students everywhere**

⭐ **Star this repo** if you find it helpful!

</div>
