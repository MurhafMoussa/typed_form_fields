# Contributing to typed_form_fields

First off, thank you for considering contributing to typed_form_fields! We welcome any help, from reporting bugs to submitting new features. Every contribution is valuable.

This document provides guidelines to help you through the contribution process.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

There are many ways to contribute, including:

- **Reporting Bugs:** If you find a bug, please create an issue in our tracker.
- **Suggesting Enhancements:** Have an idea for a new feature or an improvement? Let's discuss it in an issue.
- **Writing Documentation:** Good documentation is crucial. Help us improve the docs, README, or code comments.
- **Submitting Pull Requests:** If you're ready to contribute code, we'd love to review your work.

### Reporting Bugs

Before creating a bug report, please check the existing issues to see if someone has already reported it. When you create a new bug report, please include as many details as possible:

- A clear and descriptive title.
- A detailed description of the problem.
- Steps to reproduce the bug.
- The version of typed_form_fields you are using.
- The output of `flutter doctor -v`.
- Screenshots or GIFs if they help illustrate the issue.

### Suggesting Enhancements

If you have an idea for an enhancement, please create an issue first to discuss your idea. This allows us to align on the proposal before you put significant effort into coding it.

## Your First Code Contribution

Ready to contribute code? Here’s how to set up your environment and get started.

1. Fork the repository on GitHub.
2. Clone your fork to your local machine:
   ```sh
   git clone https://github.com/YOUR_USERNAME/typed_form_fields.git
   ```
3. Navigate to the project directory:
   ```sh
   cd typed_form_fields
   ```
4. Add the upstream repository to keep your fork in sync:
   ```sh
   git remote add upstream https://github.com/murhafsousli/typed_form_fields.git
   ```
5. Create a new feature branch from the develop branch (see Branching Strategy below):
   ```sh
   git checkout develop
   git pull upstream develop
   git checkout -b feature/your-awesome-feature
   ```
6. Make your changes, write tests, and ensure all existing tests pass.
7. Commit your changes and push them to your fork.
8. Open a Pull Request to merge your feature branch into the develop branch of the main repository.

## Branching Strategy

We follow a Simplified GitFlow model to keep the repository clean and ensure the stability of published versions.

### Core Branches

- **main:** This branch represents the latest stable, published version on pub.dev. All commits on main are tagged with a version number (e.g., v1.2.3). Never commit directly to this branch.
- **develop:** This is the primary development branch. It contains the code for the next upcoming release. All new features are merged into this branch.

### Temporary Branches

- **feature/<feature-name>:** For developing new features.
  - Branched from: develop
  - Merged into: develop
  - Example: feature/add-autocomplete-field
- **hotfix/<fix-name>:** For fixing critical bugs in a published version.
  - Branched from: main
  - Merged into: both main and develop
  - Example: hotfix/fix-date-picker-crash

## Pull Request Process

- Ensure your code adheres to the Effective Dart style guide.
- Make sure all tests pass and, if you've added new functionality, include new tests.
- Update the README.md or other documentation if your changes affect them.
- Update the CHANGELOG.md file with a concise description of your change under the "Unreleased" section.
- Your PR should be targeted to merge into the develop branch (unless it's a hotfix).
- Link your PR to any relevant issues.
- Provide a clear description of the changes in your PR.
- Once your PR is submitted, a project maintainer will review it. We may ask for changes or improvements before merging.

---

Thank you again for your interest in making typed_form_fields better!
