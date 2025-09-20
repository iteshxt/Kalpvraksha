# 🌳 Dr.Swatantra AI - Your Holistic Wellness Companion

<div align="center">
  <img src="assets/kalpvraksha_icon.png" alt="Kalpvraksha Logo" width="200"/>
  
  **A Flutter-based holistic wellness app powered by AI for mind, body, and soul well-being**
  
  [![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
  [![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
  [![Google AI](https://img.shields.io/badge/Google%20AI-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://ai.google.dev)
</div>

---

## 📱 About Dr.Swatantra AI

Dr.Swatantra AI is a comprehensive wellness application that brings together ancient wisdom and modern AI technology to help users achieve a medicine-free, stress-free, and joyful life. Named after the mythical wish-fulfilling tree, our app serves as your personal guide to holistic well-being through natural healing principles.

### ✨ Core Philosophy
- **Holistic Wellness**: Addressing mind, body, and spirit as interconnected elements
- **Natural Healing**: Emphasizing the body's innate self-healing capabilities
- **AI-Powered Guidance**: Personalized wellness recommendations through advanced AI
- **Accessible Healthcare**: Making wellness guidance available to everyone, everywhere

---

## 🎯 Key Features

### 🤖 **Dr. Swatantra AI - Your Wellness Guide**
- Compassionate AI assistant trained in holistic wellness principles
- Personalized guidance for natural healing and stress management
- Available 24/7 for wellness consultations and mental health support
- Medicine-free approach to health and well-being

### 🎙️ **Advanced Voice Interaction**
- **Speech-to-Text**: Natural conversation with the AI assistant
- **Text-to-Speech**: High-quality voice responses with customizable settings
- **Voice Presets**: Therapeutic, energetic, and calming voice options
- **Multi-language Support**: Voice interaction in multiple languages

### 🔐 **Secure Authentication System**
- **Firebase Authentication**: Secure user account management
- **Google Sign-In**: Quick and easy login with Google accounts
- **Anonymous Access**: Try the AI consultant without registration
- **Profile Management**: Personalized user profiles with wellness tracking

### 🧘 **Wellness Content & Features**
- **Daily Quotes**: Inspirational wellness quotes for motivation
- **Explore Section**: Curated wellness content and resources
- **Voice Sessions**: Interactive voice-based wellness consultations
- **Progress Tracking**: Monitor your wellness journey over time

### 🎨 **Beautiful & Adaptive UI**
- **Dark/Light Theme**: Choose your preferred visual experience
- **Gradient Backgrounds**: Soothing color schemes for relaxation
- **Smooth Animations**: Elegant transitions and interactive elements
- **Responsive Design**: Optimized for all screen sizes

---

## 🏗️ Architecture & Technology

### 📱 **Frontend (Flutter)**
```
lib/
├── main.dart                 # App entry point & theme configuration
├── auth_wrapper.dart         # Authentication state management
├── main_navigation.dart      # Bottom navigation with 5 tabs
├── splash_screen.dart        # App startup screen
├── pages/                    # UI screens and pages
│   ├── auth/                 # Authentication pages
│   │   ├── login_page.dart
│   │   ├── signup_page.dart
│   │   ├── forgot_password_page.dart
│   │   └── google_user_details_page.dart
│   ├── home_page.dart        # Dashboard with daily quotes
│   ├── explore_page.dart     # Wellness content exploration
│   ├── voice_page.dart       # Voice interaction interface
│   ├── chatbot_page.dart     # Text-based AI chat
│   ├── profile_page.dart     # User profile management
│   └── wellness_consultant_page.dart
├── services/                 # Backend integrations
│   ├── auth_service.dart     # Firebase authentication
│   ├── gemini_service.dart   # Google Gemini AI integration
│   ├── voice_assistant_service.dart # Voice processing
│   ├── voice_stream_service.dart    # Real-time voice streaming
│   └── youtube_service.dart  # Content integration
├── providers/                # State management
│   ├── theme_provider.dart   # Theme switching
│   └── navigation_provider.dart
└── widgets/                  # Reusable UI components
```

### 🔧 **Core Technologies**

#### **AI & Machine Learning**
- **Google Gemini AI**: Advanced conversational AI for wellness guidance
- **Natural Language Processing**: Understanding user queries and context
- **Personalized Responses**: Tailored advice based on user interactions

#### **Voice Technology**
- **Speech-to-Text**: Real-time voice recognition and transcription
- **Text-to-Speech**: High-quality voice synthesis with customization
- **Voice Streaming**: Real-time audio processing and response

#### **Backend Services**
- **Firebase Authentication**: Secure user management
- **Cloud Firestore**: User data and preferences storage
- **Google Sign-In**: Seamless authentication experience

#### **Media & Content**
- **Audio Players**: High-quality audio playback for guided sessions
- **Image Processing**: Profile photos and content imagery
- **Asset Management**: Optimized loading of wellness content

---

## 🚀 Getting Started

### 📋 Prerequisites

- **Flutter SDK** (>=3.8.0)
- **Dart SDK** (included with Flutter)
- **Android Studio** or **VS Code** with Flutter extensions
- **Firebase Project** with Authentication and Firestore enabled
- **Google Gemini API Key**

### 🛠️ Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/CodeXdhruv/Kalpvraksha.git
   cd Kalpvraksha
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   Create a `.env` file in the root directory:
   ```env
   GEMINI_API_KEY=your_gemini_api_key_here
   ```

4. **Configure Firebase**
   - Add your `google-services.json` file to `android/app/`
   - Add your `GoogleService-Info.plist` file to `ios/Runner/`

5. **Run the application**
   ```bash
   flutter run
   ```

### 🔑 API Keys Setup

#### **Google Gemini API**
1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create a new API key
3. Add it to your `.env` file

#### **Firebase Configuration**
1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Enable Authentication (Email/Password and Google Sign-In)
3. Enable Cloud Firestore
4. Download configuration files and add to your project

---

## 📱 App Navigation & UI

### 🏠 **Home Page**
- **Daily Wellness Quotes**: Inspirational content rotated daily
- **Quick Access**: Direct links to AI consultant and voice assistant
- **Wellness Progress**: Visual indicators of your wellness journey
- **Beautiful Gradients**: Soothing color schemes that adapt to time of day

### 🔍 **Explore Page**
- **Wellness Content**: Curated articles, tips, and resources
- **Categories**: Mental health, physical wellness, spiritual growth
- **Interactive Elements**: Engaging content with smooth animations
- **Personalized Recommendations**: Content tailored to your interests

### 🎙️ **Voice Assistant**
- **Real-time Conversation**: Natural dialogue with Dr. Swatantra AI
- **Voice Customization**: Adjust pitch, speed, and tone
- **Visual Feedback**: Beautiful waveform animations during interaction
- **Session History**: Review past voice consultations

### 💬 **AI Chatbot**
- **Text-based Conversations**: Deep discussions about wellness topics
- **Contextual Responses**: AI remembers conversation history
- **Wellness Guidance**: Personalized advice and recommendations
- **24/7 Availability**: Always available for support and guidance

### 👤 **Profile Management**
- **User Information**: Manage personal details and preferences
- **Wellness Goals**: Set and track your health objectives
- **Settings**: Customize app experience and privacy settings
- **Progress Analytics**: View your wellness journey statistics

---

## 🎨 Design Philosophy

### 🌈 **Color Palette**
- **Light Theme**: Warm oranges (#E86D4C, #FF8F6E) for energy and vitality
- **Dark Theme**: Deep purples (#2A1F5D, #8B6EFF) for tranquility and focus
- **Gradients**: Smooth color transitions for visual harmony

### ✨ **User Experience**
- **Intuitive Navigation**: Clear, easy-to-understand interface
- **Smooth Animations**: Elegant transitions that enhance usability
- **Accessibility**: Designed for users of all abilities
- **Responsive Design**: Consistent experience across all devices

### 🎭 **Visual Elements**
- **Custom Icons**: Thoughtfully designed icons that reflect wellness themes
- **Typography**: Readable fonts that promote calm and focus
- **Spacing**: Generous whitespace for reduced cognitive load
- **Interactive Feedback**: Clear visual responses to user actions

---

## 🔐 Authentication & Security

### 🛡️ **Authentication Methods**

#### **Email & Password**
- Secure account creation and login
- Password reset functionality
- Email verification for enhanced security

#### **Google Sign-In**
- One-tap authentication with Google accounts
- Automatic profile information sync
- Enhanced security through Google's infrastructure

#### **Anonymous Access**
- Try the AI consultant without registration
- Limited feature access for privacy-conscious users
- Easy upgrade to full account when ready

### 🔒 **Security Features**
- **Firebase Security Rules**: Protecting user data in Firestore
- **Encrypted Communications**: All API calls use HTTPS encryption
- **Local Data Protection**: Sensitive information encrypted on device
- **Privacy Controls**: Users control their data sharing preferences

---

### 🎙️ **Voice Technology Features**

#### **Advanced Speech Recognition**
- Real-time speech-to-text conversion
- Multiple language support
- Noise cancellation and enhancement
- Context-aware understanding

#### **Intelligent Text-to-Speech**
- Natural-sounding voice synthesis
- Customizable voice parameters:
  - **Pitch**: 0.5 to 2.0 range
  - **Speech Rate**: 0.0 to 1.0 range
  - **Volume**: 0.0 to 1.0 range
- Voice presets for different moods:
  - **Therapeutic**: Calm and soothing
  - **Energetic**: Upbeat and motivating
  - **Balanced**: Natural and conversational

#### **Voice Interaction Flow**
```
User Speaks → Speech Recognition → AI Processing → Response Generation → Text-to-Speech → Audio Output
```

---

## 📦 Dependencies & Packages

### 🔧 **Core Framework**
```yaml
dependencies:
  flutter: sdk
  dart: ">=3.8.0 <4.0.0"
```

## 🚀 Build & Deployment

### 📱 **Android Build**
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# App Bundle for Play Store
flutter build appbundle --release
```

### 🍎 **iOS Build**
```bash
# iOS build
flutter build ios --release

# Archive for App Store
flutter build ipa
```

### 🌐 **Web Build**
```bash
# Web build
flutter build web --release
```

### 🏗️ **Build Configuration**

#### **Android Configuration**
- **Minimum SDK**: API 21 (Android 5.0)
- **Target SDK**: Latest stable
- **App Signing**: Release keystore configured
- **Permissions**: Microphone, internet, storage

#### **iOS Configuration**
- **Minimum Version**: iOS 12.0
- **Privacy Descriptions**: Microphone usage explained
- **App Store Guidelines**: Compliant with health app requirements

---

## 🧪 Testing

### 🔍 **Test Structure**
```
test/
├── widget_test.dart            # UI component tests
├── voice_api_test.dart         # Voice service tests
└── integration_tests/          # End-to-end tests
```

### 🚀 **Running Tests**
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Coverage report
flutter test --coverage
```

---

## 🤝 Contributing

We welcome contributions to make Kalpvraksha even better! Here's how you can help:

### 🛠️ **Development Setup**
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes and test thoroughly
4. Commit your changes: `git commit -m 'Add amazing feature'`
5. Push to the branch: `git push origin feature/amazing-feature`
6. Open a Pull Request

### 📝 **Contribution Guidelines**
- Follow Flutter/Dart coding conventions
- Write tests for new features
- Update documentation for significant changes
- Ensure accessibility compliance
- Test on multiple devices and platforms

### 🐛 **Bug Reports**
- Use GitHub Issues for bug reports
- Include device information and steps to reproduce
- Attach screenshots or recordings when helpful

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Google Gemini AI** for advanced conversational capabilities
- **Firebase** for robust backend infrastructure
- **Flutter Community** for excellent packages and support
- **Wellness Experts** who helped shape Dr. Swatantra AI's knowledge base

---

## 📞 Support & Contact

- **Developer**: CodeXdhruv
- **Email**: dhruvsen24@gmail.com
- **GitHub**: [@CodeXdhruv](https://github.com/CodeXdhruv)
- **Issues**: [Report bugs or request features](https://github.com/CodeXdhruv/Kalpvraksha/issues)

---

## 🌟 Future Roadmap

### 🔮 **Upcoming Features**
- **Meditation Sessions**: Guided meditation with voice instructions
- **Wellness Tracking**: Health metrics and progress visualization
- **Community Features**: Connect with other wellness enthusiasts
- **Wearable Integration**: Sync with fitness trackers and smartwatches
- **Multilingual Support**: AI assistant in multiple languages
- **Offline Mode**: Core features available without internet

### 🎯 **Long-term Vision**
- **AI Personalization**: Deeper learning of user preferences and needs
- **Healthcare Integration**: Connect with healthcare providers
- **Global Wellness Community**: Worldwide network of wellness practitioners
- **Research Contributions**: Support wellness research initiatives

---

<div align="center">
  <h3>🌳 Dr.Swatantra AI - Nurturing Wellness, Naturally 🌳</h3>
  <p><em>Your journey to holistic well-being starts here</em></p>
  
  **Made with ❤️ by CodeXdhruv**
</div>