# Augma Aura - Your Personal Emotion Tracking Companion

## 🌟 Overview
Augma Aura is a sophisticated emotion tracking application designed to help users monitor, understand, and manage their emotional well-being. Built with Flutter, it offers a beautiful, intuitive interface with both standard and immersive modes for a personalized user experience.

## ✨ Features

### Core Features
- **Emotion Tracking**: Log and monitor your daily emotions
- **Dual Interface Modes**:
  - Standard Mode: Traditional app interface
  - Immersive Mode: Full-screen, focused experience
- **Personalized Experience**:
  - Customizable user name
  - Dark theme with red accents
  - Modern, clean UI design

### Notification System
- **Smart Daily Reminders**:
  - 6:00 AM - Start your day
  - 9:00 AM - Set your intentions
  - 4:00 PM - Daily check-in
  - 6:00 PM - Evening sync
  - 8:00 PM - Daily log reminder
  - 9:31 PM - Final reminder

### Technical Features
- **Cross-Platform**: iOS and Android support
- **Local Storage**: Secure data persistence
- **Responsive Design**: Adapts to various screen sizes
- **Smooth Animations**: Enhanced user experience
- **Time Zone Support**: Accurate local notifications

## 🛠️ Technical Stack

### Frontend
- **Framework**: Flutter
- **Language**: Dart
- **UI Components**: Material Design
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **Notifications**: Flutter Local Notifications Plugin

### Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  google_fonts: ^6.1.0
  shared_preferences: ^2.2.2
  flutter_local_notifications: ^16.3.2
  timezone: ^0.9.2
  intl: ^0.19.0
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest version)
- Dart SDK (latest version)
- Android Studio / Xcode
- Git

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/augma_aura.git
   ```

2. Navigate to project directory:
   ```bash
   cd augma_aura
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## 📱 App Structure

### Main Components
- **Main App**: Entry point and navigation setup
- **Emotion Tracking Page**: Core emotion logging interface
- **Settings Page**: User preferences and app configuration
- **Notification Service**: Handles all notification scheduling

### Key Files
- `lib/main.dart`: Main application entry point
- `lib/pages/emotion_tracking_page.dart`: Emotion tracking interface
- `lib/pages/settings_page.dart`: Settings and configuration
- `lib/services/notification_service.dart`: Notification management

## 🎨 UI/UX Design

### Color Scheme
- Primary: Dark theme with red accents
- Secondary: White text and icons
- Accent: Red[900] for important elements

### Typography
- Primary Font: Orbitron (for headings)
- Secondary Font: Nunito (for body text)

### Layout
- Responsive design
- Adaptive padding and margins
- Consistent spacing system

## 🔔 Notification System

### Configuration
- Local timezone support
- Exact timing delivery
- High priority notifications
- Custom notification sounds

### Schedule
- Morning notifications (6 AM, 9 AM)
- Afternoon check-in (4 PM)
- Evening reminders (6 PM, 8 PM, 9:31 PM)

## 💾 Data Management

### Local Storage
- User preferences
- Emotion logs
- App settings
- Notification preferences

### Security
- Local data storage
- No cloud synchronization
- Privacy-focused design

## 🛠️ Development Guidelines

### Code Style
- Follow Flutter style guide
- Use meaningful variable names
- Document complex functions
- Maintain consistent formatting

### Best Practices
- Use const constructors
- Implement proper error handling
- Follow widget tree optimization
- Maintain clean architecture

## 📈 Performance Optimization

### Key Optimizations
- Efficient widget rebuilding
- Optimized image loading
- Proper state management
- Memory leak prevention

### Best Practices
- Use const widgets
- Implement proper disposal
- Optimize list views
- Cache expensive operations

## 🔧 Troubleshooting

### Common Issues
1. **Notification Timing**
   - Ensure correct timezone settings
   - Check notification permissions
   - Verify notification channel setup

2. **UI Rendering**
   - Clear app cache
   - Restart the app
   - Check device compatibility

3. **Data Persistence**
   - Verify storage permissions
   - Check storage space
   - Clear app data if needed

## 📱 Platform-Specific Notes

### iOS
- Requires notification permissions
- Needs proper entitlements
- Follows iOS design guidelines

### Android
- Requires notification channels
- Needs proper permissions
- Follows Material Design

## 🔄 Update Process

### Version Updates
1. Update dependencies
2. Test on both platforms
3. Verify notification timing
4. Check UI consistency

### Data Migration
- Handle version changes
- Preserve user data
- Update storage schema

## 📚 Additional Resources

### Documentation
- Flutter Documentation
- Dart Documentation
- Plugin Documentation

### Support
- GitHub Issues
- Stack Overflow
- Flutter Community

## 🤝 Contributing

### How to Contribute
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

### Code Review Process
- Follow style guide
- Add proper documentation
- Include tests
- Update README if needed

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments
- Flutter Team
- Plugin Developers
- Open Source Community

## 📞 Contact
For support or inquiries, please contact:
- Email: your.email@example.com
- GitHub: yourusername

## 🔮 Future Plans
- [ ] Cloud synchronization
- [ ] Advanced analytics
- [ ] Custom themes
- [ ] Export functionality
- [ ] Social features

---

*Last updated: [Current Date]*
