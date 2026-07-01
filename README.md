# BCAMusicPlayer

A scalable iOS music player built with **SwiftUI**, architected with the **MVVM (Model-View-ViewModel)** design pattern and **Combine**, focusing on testability, clean separation of concerns, and modern async Swift.

## Overview
BCAMusicPlayer consumes the **iTunes Search API** to let users search for songs, browse results, and preview tracks. The project was built as a technical assessment to demonstrate production-grade iOS architecture, from networking and state management down to automated testing and delivery.

## Features
- **Search:** Query the iTunes Search API in real time and browse matching tracks.
- **Playback:** Preview audio clips directly within the app.
- **Reactive State:** UI state driven by `@Published` properties and Combine pipelines.
- **Async Networking:** API calls implemented with Swift's native `async/await`.
- **Error Handling:** Graceful handling of network failures, empty states, and malformed responses.

## Architecture
The app follows **MVVM**:
- **Model:** Codable structs mapping iTunes Search API responses.
- **ViewModel:** Owns business logic and exposes state via `@Published` properties; consumed reactively by views through Combine.
- **View:** Declarative SwiftUI views that bind to ViewModel state and remain free of business logic.
- **Service Layer:** Dedicated networking and audio playback services, decoupled from ViewModels via protocol abstractions to enable mocking in unit tests.

## Tech Stack
- **UI:** SwiftUI
- **Reactive:** Combine
- **Concurrency:** Swift Concurrency (`async/await`)
- **Networking:** URLSession consuming the iTunes Search API
- **Testing:** XCTest
- **CI/CD:** GitHub Actions (automated build + test on every push/PR)

## CI/CD Pipeline
- **Continuous Integration:** GitHub Actions automatically builds the project and runs the full unit test suite on every push and pull request to `main`, with manual dispatch also available.
- **Build Environment:** Runs on `macos-latest` with the latest stable Xcode toolchain, targeting an iPhone 17 iOS Simulator destination.
- **Testing:** Executes `xcodebuild test` against the `BCAMusicPlayer` scheme, with output piped through `xcpretty` for readable logs. Code signing is disabled for CI runs (`CODE_SIGNING_REQUIRED=NO`) since the pipeline only needs to build and test.
- **Continuous Deployment:** Not currently implemented. TestFlight distribution requires an active Apple Developer Program membership, which this project doesn't currently have.
- **Status:** ✅ CI pipeline is live and passing — see the [Actions tab](https://github.com/WilliamKesuma/BCAMusicPlayer/actions) for the latest run.

## How to Run
1. **Clone the repository:**
   ```bash
   git clone https://github.com/WilliamKesuma/BCAMusicPlayer.git
   ```
2. **Open in Xcode:** Open `BCAMusicPlayer.xcodeproj`.
3. **Configure Signing:** Navigate to **Signing & Capabilities** in the target settings. Select your personal Apple ID from the **Team** dropdown to enable automatic code signing.
4. **Run the app:** Select a simulator or device and press `Cmd + R`.
5. **Run Tests:** Use `Cmd + U` to execute the full unit test suite.

## Instructions for Contributors
1. Fork/clone the repository and open `BCAMusicPlayer.xcodeproj` in Xcode.
2. If you need to run the app on a physical device, go to **Signing & Capabilities** and select your personal Apple ID from the **Team** dropdown to enable automatic code signing. This is not required to build or test in the simulator.
3. Make your changes and run the test suite (`Cmd + U`) before opening a pull request.
4. Push to a branch and open a PR against `main` — the GitHub Actions workflow will automatically build and run the full test suite on an iOS simulator.

## Testing Strategy
- The app uses asynchronous MVVM, so ViewModels are tested independently of the UI using dependency-injected mock services.
- Use the **Test** scheme (`Cmd + U`) to execute the test suite.
- Tests cover: API response decoding, ViewModel state transitions, search debouncing/filtering logic, and error handling paths.

## Project Structure
```
BCAMusicPlayer/
├── App/            # Main application entry point
├── Models/         # Data structures and API response models
├── ViewModels/     # Business logic and state management
├── Views/          # SwiftUI components and UI layout
├── Services/       # Networking and audio playback services
└── Tests/          # Unit tests for ViewModels and services
```

## Author
**William Sanjaya Kesuma**
[GitHub](https://github.com/WilliamKesuma) · [LinkedIn](https://linkedin.com/in/williamskesuma)
