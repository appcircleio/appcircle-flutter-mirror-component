# Appcircle Flutter Mirror

This step points pub and the Flutter tool at your artifact proxy (for example a Sonatype Nexus or JFrog Artifactory), so Flutter builds work on runners without internet access.

Place it after Git Clone, next to the other mirror steps, and before Flutter Install. It sets two environment variables for the later steps of the build and writes nothing to the runner, so its exact place does not matter as long as Flutter Install comes after it. If both inputs are empty, the step does nothing.

For the Android part of a Flutter build, add the Gradle Mirror step too. For iOS projects with CocoaPods, add the CocoaPods mirror step.

## Optional Input Variables

- `$AC_MIRROR_PUB`: URL of a pub repository on your artifact proxy, a proxy of `https://pub.dev`. Becomes `PUB_HOSTED_URL` for the later steps.
- `$AC_MIRROR_FLUTTER`: URL of a raw (generic) repository on your artifact proxy, a proxy of `https://storage.googleapis.com`. Becomes `FLUTTER_STORAGE_BASE_URL` for the later steps. The following all read it:
  - Flutter Install, which downloads the Flutter SDK;
  - the Flutter tool and the Flutter Gradle plugin, which download the engine artifacts.

Set the values once in an Environment Variable Group and add the group to the configurations that use the step.

## Artifact Proxy Setup

| Repository | Type | Remote URL | Used for |
| --- | --- | --- | --- |
| pub | pub proxy | `https://pub.dev` | Packages in `pubspec.yaml` |
| Flutter storage | raw (generic) proxy | `https://storage.googleapis.com` | The Flutter SDK archives and `releases_macos.json` (`flutter_infra_release/`), engine artifacts (`download.flutter.io/`) |
| Flutter engine (Maven) | Maven 2 proxy, in the Gradle Mirror group | `https://storage.googleapis.com/download.flutter.io/` | Projects that do not set `AC_MIRROR_FLUTTER`: the Gradle Mirror step sends the engine repository to its group |

The pub proxy must allow anonymous read. pub sends credentials only as a bearer token, and Sonatype Nexus Repository (Community Edition) accepts only basic authentication on a pub proxy. The Flutter tool also downloads from `FLUTTER_STORAGE_BASE_URL` without credentials.

## What You Configure in the Project

- `git:` dependencies in `pubspec.yaml` are cloned with git and do not go through the pub proxy. Mirror those repositories on your git server; the git mirror step points git at them.
- A `hosted:` URL in `pubspec.yaml` other than pub.dev is used as written.

## Limits

- Every `flutter` command checks for a newer Flutter version on `github.com` first. Without internet access the check waits for a connection timeout, about 75 seconds, once per command. This step cannot prevent it, because it runs before the SDK is installed. It goes away when the SDK is installed with a fresh version check stamp (`bin/cache/flutter_version_check.stamp`), which the Flutter Install step is to write after the installation.
