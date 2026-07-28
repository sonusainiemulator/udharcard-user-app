# AGENTS.md - Udharcard Mobile App AI & GitOps Guidelines

> **Notice**: This repository is maintained under strict **GitOps** principles. All modifications to codebase, configurations, and workflows must be performed via Git commits and validated by automated CI/CD pipelines.

## Quick Links
- 🤖 [Workspace Agent Guidelines & Rules](.agents/AGENTS.md)
- ⚙️ [GitHub Agent & GitOps Maintenance Manual](.github/AGENTS.md)
- 🚀 [CI/CD Workflow Directory](.github/workflows/)

## GitOps Enforcement Summary
1. **Single Source of Truth**: All app parameters, branding (Udharcard), dependencies, and workflow scripts live in Git.
2. **Automated Validation**: `flutter analyze` and `flutter test` must pass clean before any pull request is merged.
3. **No Direct Overrides**: Do not modify runtime configs out-of-band. Everything must be declared in repo commits.
4. **Secret Protection**: `.env` handles sensitive API keys (e.g. Gemini AI, Firebase); never commit raw keys to Git.
