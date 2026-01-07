# Testing app

An example illustrates how to test and setup code coverage in a Flutter application.

## Overview

This project is a sample Flutter application focused on sample-data
functionality. It includes unit tests, integration and supports code coverage reporting to help evaluate test quality and completeness.

## Testing

### Generating Coverage Reports

To run all tests and generate a coverage report, execute the following
command from the project root:

``` bash
flutter test --coverage
```

This command runs the entire test suite and generates a
`coverage/lcov.info` file, which contains raw coverage data in LCOV
format.

#### Running a Specific Test File

If you only want to run coverage for a specific test file, use:

``` bash
flutter test ./test/weather_repository_test.dart --coverage
```

### Viewing Coverage Reports

The generated `lcov.info` file is not human-readable by default. You can
inspect coverage results using one of the following approaches.

#### 1. IDE Integration (VS Code, Android Studio, IntelliJ)

Most modern IDEs support LCOV through extensions or built-in tooling,
allowing you to visualize coverage directly in the source code.

**VS Code extensions:**

-   **Coverage Gutters**\
    Displays line-by-line coverage using visual indicators (covered
    vs. uncovered lines).

-   **Flutter Coverage**\
    Provides a structured tree view with coverage percentages per file
    and directory.

These tools are useful for quick feedback during development.

#### 2. HTML Coverage Report

For a more comprehensive and user-friendly view, you can generate an
HTML report using the `lcov` command-line tool.

**Install `lcov`:**

-   macOS (Homebrew):

    ``` bash
    brew install lcov
    ```

-   Other operating systems: install via the appropriate package
    manager.

**Generate the HTML report:**

``` bash
genhtml coverage/lcov.info -o coverage/html
```

**View the report:**

Open `coverage/html/index.html` in a web browser to explore detailed
coverage statistics at the project, directory, and file levels.

## References

- Official [Testing Flutter apps](https://docs.flutter.dev/testing/overview) document.
- [How to test a Flutter app](https://codelabs.developers.google.com/codelabs/flutter-app-testing#0) codelab.
