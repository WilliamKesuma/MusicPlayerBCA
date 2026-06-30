# BCAMusicPlayer

A scalable iOS music player architected with the **MVVM (Model-View-ViewModel)** design pattern, focusing on testability and clean separation of concerns.

## CI/CD Pipeline
- **GitHub Actions:** Automated CI pipeline configured to run unit tests on every push.
- **Testing:** Comprehensive test suite for ViewModel logic, ensuring business requirements are validated.
- **Deployment Strategy:** Configured for automated TestFlight distribution. The project uses **Automatic Code Signing**. 

## Instructions for Contributors
To build and upload to TestFlight:
1. Open the project in Xcode.
2. Navigate to **Signing & Capabilities** in the target settings.
3. Select your personal Apple ID from the **Team** dropdown to allow Xcode to manage development certificates automatically.
4. Ensure the **Bundle Identifier** is set to a unique value if required.

## Testing Strategy
- The app uses asynchronous MVVM. Use the 'Test' scheme (Cmd+U) to execute the test suite.
