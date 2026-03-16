# Pixelo

Pixelo is a Flutter recreation of the Instagram home feed with a strong focus on spacing accuracy, gesture polish, and feed-state architecture.

## What Is Implemented

- Instagram-style home app bar, stories tray, and vertically scrolling feed.
- Post carousels with synchronized indicators and image-count chip.
- Pinch-to-zoom image overlay that lifts above the feed and animates back on release.
- Local like and save toggles with double-tap like animation.
- Floating custom snackbars for unimplemented actions such as comments, share, notifications, and messages.
- Shimmer loading states for stories, initial posts, and pagination.
- Lazy loading that requests the next page when the user is roughly two posts from the bottom.
- Public network image URLs only for feed content, with `cached_network_image` handling caching and fallbacks.

## State Management Choice

This project uses Riverpod.

The feed is managed with an `AsyncNotifierProvider`, which keeps loading, pagination, and local interaction state in one place. That keeps UI widgets mostly declarative while still allowing optimistic updates for like/save toggles and seamless append behavior during infinite scrolling.

## Project Structure

- `lib/models`: feed entities such as post, story, reel, and user.
- `lib/services`: mock repository layer with delayed futures/streams.
- `lib/providers`: Riverpod providers and notifiers.
- `lib/widgets`: reusable feed UI pieces such as story tray, post card, shimmer, and pinch-to-zoom.
- `lib/screens`: screen composition for the app shell and detail screens.

## Installation

### Prerequisites

Before you begin, ensure you have met the following requirements:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed (Stable channel recommended).
- An IDE such as **VS Code** or **Android Studio** with Flutter and Dart plugins installed.
- Android Studio (for Android) or Xcode (for iOS on macOS) installed for platform-specific tooling.

### Setup Steps

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/praaatap/Pixelo
    cd pixelo
    ```

2.  **Install dependencies:**
    Run the following command to fetch all required packages listed in `pubspec.yaml`:
    ```bash
    flutter pub get
    ```

## Running The App

1.  **Launch a device:**
    - Open your Android Emulator or iOS Simulator.
    - Or connect a physical device via USB (ensure USB Debugging is on for Android).

2.  **Run the application:**
    Execute the following command in your terminal:
    ```bash
    flutter run
    ```

    You can also select a specific device if multiple are connected:
    ```bash
    flutter run -d <device-id>
    ```