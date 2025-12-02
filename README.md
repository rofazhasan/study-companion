# Study Companion

A powerful, AI-powered study assistant built with Flutter.

## Features

### 🧠 AI Chat & Quiz Generation
- **Interactive Chat**: Ask questions and get instant answers from Gemini AI.
- **Quiz Generation**: Automatically generate quizzes on any topic.
- **Flashcards**: Create flashcards from your study materials.

### ⚔️ Social Battle Mode
- **Real-time Battles**: Challenge friends to quiz battles.
- **Host Controls**: Create lobbies, add bots, and manage the game.
- **Leaderboards**: Track your rankings and view detailed battle history.
- **Detailed Analytics**: Review time taken per question and correct answers.

### 📚 Study Tools
- **Pomodoro Timer**: Stay focused with a built-in focus timer.
- **Notes**: Organize your study notes.

## Getting Started

### Prerequisites
- Flutter SDK (3.10+)
- Dart SDK (3.0+)
- Firebase Project (for Auth and Firestore)
- Gemini API Key

### Setup
1.  **Clone the repository**:
    ```bash
    git clone https://github.com/yourusername/study_companion.git
    cd study_companion
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Configure Firebase**:
    - Install `flutterfire_cli`.
    - Run `flutterfire configure`.

4.  **Run the app**:
    ```bash
    flutter run
    ```

## Architecture
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Database**: Firebase Firestore (Cloud) & Isar (Local)
- **AI**: Google Gemini

## Version
Current Version: 0.4.0
