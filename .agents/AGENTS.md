# Udharcard User App - Agent Guidelines & GitOps Operations

## Core Principles & GitOps Philosophy
1. **Git as Single Source of Truth**: All configuration, infrastructure adjustments, features, and UI modifications must be declaratively versioned in Git. Direct manual overrides or non-reproducible edits are strictly forbidden.
2. **Automated Verification**: Every change proposed or executed by an agent must pass automated linting (`flutter analyze`) and unit tests (`flutter test`) prior to committing.
3. **Mandatory Changelog Maintenance**: Every completed feature, bugfix, or refactor task MUST update `CHANGELOG.md` with version details under `[VERSION] - YYYY-MM-DD`.
4. **Auto-Push & Binary Releases**: Upon completing a task, changes must be automatically staged, committed using Conventional Commits, and pushed to GitHub. The GitHub Actions release pipeline (`.github/workflows/release.yml`) builds both **Debug APK (`app-debug.apk`)** and **Release APK (`app-release.apk`)** for instant availability on the GitHub Releases page.
5. **Rebranding Consistency**: The application is branded as **Udharcard** (formerly PaySecure). Ensure app titles, display names, constants (`AppConstants.appName`), and assets adhere strictly to Udharcard branding.
6. **Secret Management**: Never commit API keys or sensitive credentials into tracked files. Use `.env` and retrieve keys via `flutter_dotenv`.

## Development & Code Standards
- **Flutter Framework & Architecture**: Use GetX (`get` package) for state management and navigation. Maintain separation between views (`lib/views/`), controllers (`lib/controllers/`), and services (`lib/services/`).
- **Voice Mode & AI Features**: Gemini AI operations must be encapsulated in `lib/services/ai_service.dart`. Voice recognition & TTS must reside in `lib/services/voice_service.dart`.
- **UI & Responsiveness**: Use `flutter_screenutil` (`.h`, `.w`, `.sp`, `.r`) for scalable layouts across screen sizes. Utilize `AppColors` for consistent color schemes.
- **Deprecation Cleanliness**: Prefer `Color.withValues(alpha: x)` over `withOpacity(x)` for modern Flutter compatibility.

## GitOps Workflow & Execution Rules
1. **Branching Strategy**:
   - `main` / `master`: Production-ready branch. All changes must be delivered via Pull Requests.
   - Feature branches: `feature/voice-mode`, `fix/login-auth`, `gitops/ci-updates`.
2. **Commit Message Format**: Follow Conventional Commits:
   - `feat(voice): add Gemini voice assistant with Hindi TTS`
   - `fix(rebrand): update display name to Udharcard in app constants`
   - `ci(gitops): add GitOps state verification workflow`
3. **Automated PR & Review Requirement**:
   - Every modification must be validated by running `flutter analyze` and `flutter test`.
   - Never skip broken build steps or suppress failed test assertions. Fix the root cause.
