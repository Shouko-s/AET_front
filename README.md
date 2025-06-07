# AET Preparation App – Frontend

A modern mobile application for exam preparation, built with Flutter.

---

## Features

- User registration and authentication
- Password reset via email (with code verification)
- Profile management (edit name, change email with confirmation)
- Exam/test modules with scoring
- Responsive and intuitive UI
- Secure local storage for tokens and user data

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.7.0 or higher)
- Android Studio, Xcode, or another IDE for Flutter development

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/Shouko-s/AET_front
   cd aet_front
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

---

## Project Structure

- `lib/` – Main application code
- `assets/` – Images, videos, and other assets
- `models/` – Data models
- `test/` – Unit and widget tests

---

## Main Dependencies

- `http` – HTTP requests
- `shared_preferences` – Local storage
- `flutter_secure_storage` – Secure storage for sensitive data
- `flutter_html` – Render HTML content
- `flip_card` – Interactive card widgets
- `video_player`, `chewie` – Video playback
- `intl` – Internationalization

See `pubspec.yaml` for the full list.

---

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

---

## License

This project is licensed under the MIT License.
