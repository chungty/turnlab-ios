fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios create_iap

```sh
[bundle exec] fastlane ios create_iap
```

Create In-App Purchase

### ios archive

```sh
[bundle exec] fastlane ios archive
```

Build and archive the app

### ios upload

```sh
[bundle exec] fastlane ios upload
```

Upload to App Store Connect

### ios release

```sh
[bundle exec] fastlane ios release
```

Full release: archive and upload

### ios upload_metadata

```sh
[bundle exec] fastlane ios upload_metadata
```

Upload metadata and screenshots only (no binary)

### ios upload_metadata_only

```sh
[bundle exec] fastlane ios upload_metadata_only
```

Upload metadata only (no screenshots, no binary)

### ios upload_metadata_safe

```sh
[bundle exec] fastlane ios upload_metadata_safe
```

Upload metadata without review info (workaround for first submission)

### ios submit_for_review

```sh
[bundle exec] fastlane ios submit_for_review
```

Submit app for App Store review

### ios upload_testflight

```sh
[bundle exec] fastlane ios upload_testflight
```

Upload to TestFlight

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build and upload to TestFlight

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
