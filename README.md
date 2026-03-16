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

## Demo Checklist

Record a short demo showing:

- shimmer loading for the initial feed load,
- infinite scroll loading additional posts,
- pinch-to-zoom on a feed image,
- like/save state toggles and the custom snackbars.

## Demo Recording Guide (Submission Requirement)

Use either of these outputs:

- h.264 MP4 file (preferred for offline review), or
- Loom link.

Recommended sequence (45-90 seconds total):

1. Launch app to Home feed and wait for shimmer placeholders to disappear.
2. Scroll continuously to show smooth feed motion and pagination loading.
3. Open a multi-image post, swipe carousel, then perform pinch-to-zoom and release.
4. Toggle Like and Save on at least two posts to demonstrate persistent local state changes.

### Android Capture (h.264 MP4)

1. Connect a physical Android device with USB debugging enabled.
2. Run app: `flutter run`.
3. In another terminal, start recording:
	`adb shell screenrecord /sdcard/pixelo_demo.mp4`
4. Perform the demo flow above, then stop recording with `Ctrl+C`.
5. Pull video file:
	`adb pull /sdcard/pixelo_demo.mp4 ./pixelo_demo.mp4`

### Loom Capture

1. Open Loom desktop app or Loom Chrome extension.
2. Record the emulator/device window only (avoid IDE clutter).
3. Follow the same 4-step demo sequence.
4. Share the generated Loom link in your submission.

Quality note: prioritize spacing fidelity and pinch-to-zoom polish over adding extra screens.
