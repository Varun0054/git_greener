# 🌱 GitHub Greener

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)

Keep your GitHub contribution graph lush and green! 🌿 GitHub Greener is a beautiful mobile app that helps developers maintain consistent coding habits by visualizing contribution activity, tracking streaks, and providing AI-powered commit suggestions.

![App Preview](https://via.placeholder.com/800x400/4CAF50/FFFFFF?text=GitHub+Greener+App+Preview)

## ✨ Features

### 🔥 Streak Tracking
- **Current Streak**: Track consecutive days with commits
- **Longest Streak**: Your personal best record
- **Daily Reminders**: Customizable push notifications to keep you motivated
- **Streak Protection**: Never let your green streak fade away!

### 📊 Contribution Visualization
- **GitHub-Style Graph**: Authentic contribution calendar with 5 color shades
- **Interactive Cells**: Tap any day to see commit details
- **Year Navigation**: Swipe to view current and previous years
- **Real-time Updates**: Always up-to-date with your latest activity

### 🗺️ Activity Heatmap
- **Multiple Views**: Analyze patterns by day of week, week of year, or month
- **Productivity Insights**: Discover your most active periods
- **Visual Analytics**: Beautiful charts powered by FL Chart

### 🤖 AI Commit Suggestions
- **Smart Recommendations**: AI analyzes your repos, languages, and activity
- **Actionable Ideas**: Get specific suggestions like "Add README to flutter-todo"
- **One-Tap Copy**: Easily copy suggestions to your clipboard
- **Context-Aware**: Tailored to your coding habits and projects

### 🔐 Secure Authentication
- **GitHub PAT**: Secure token-based authentication
- **Encrypted Storage**: Your token is safely stored locally
- **Profile Integration**: Display your GitHub avatar and username

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.10.4)
- Dart SDK (^3.10.4)
- Android Studio or Xcode for mobile development
- A GitHub Personal Access Token (PAT) with `read:user` and `read:org` permissions

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/github-greener.git
   cd github-greener
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

**Android APK:**
```bash
flutter build apk --release
```

**iOS (on macOS):**
```bash
flutter build ios --release
```

## 📱 Usage

1. **First Launch**: Enter your GitHub Personal Access Token
2. **Home Screen**: View your contribution graph and current streak
3. **Heatmap**: Analyze your activity patterns in detail
4. **Suggestions**: Get AI-powered commit ideas
5. **Settings**: Manage your token and notification preferences

## 🛠️ Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Riverpod
- **Routing**: Go Router
- **Charts**: FL Chart
- **Storage**: Flutter Secure Storage
- **HTTP Client**: HTTP package
- **Notifications**: Flutter Local Notifications
- **Icons**: Google Fonts, Flutter SVG

## 📁 Project Structure

```
lib/
├── models/          # Data models
├── providers/       # Riverpod state providers
├── screens/         # UI screens
├── services/        # API and business logic
├── widgets/         # Reusable UI components
└── app.dart         # Main app configuration
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by GitHub's contribution graph
- Built with ❤️ using Flutter
- Special thanks to the open-source community

## 📞 Support

If you have any questions or need help:
- Open an issue on GitHub
- Check the [documentation](docs/)
- Join our [Discord community](https://discord.gg/github-greener)

---

**Keep coding, stay green! 🌱**
