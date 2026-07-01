# BCAMusicPlayer

A scalable, professional-grade iOS music player architected with the **MVVM (Model-View-ViewModel)** design pattern. This project is built with a focus on testability, modularity, and automated quality assurance.

## Key Engineering Decisions
* **Architecture:** Implemented using **MVVM** to ensure a clean separation between business logic and UI components.
* **Concurrency:** Utilizes `async/await` and `Combine` for modern, responsive data handling.
* **Test-Driven Development:** Includes a robust suite of unit tests covering `PlayerViewModel` and `SearchViewModel` logic.
* **CI/CD Pipeline:** Configured with **GitHub Actions** to automate the build and testing lifecycle on every push.

## Technical Stack
* **Language:** Swift
* **Frameworks:** SwiftUI, Combine, XCTest
* **Networking:** URLSession with custom API service layer

## CI/CD Architecture


- **Continuous Integration:** Every commit triggers an automated build and test process via GitHub Actions.
- **Verification:** The CI pipeline ensures that all new code changes adhere to the project's quality standards and pass the comprehensive test suite before merging.

## How to Run
1. **Clone the repository:**
   ```bash
   git clone [https://github.com/WilliamKesuma/BCAMusicPlayer.git](https://github.com/WilliamKesuma/BCAMusicPlayer.git)
