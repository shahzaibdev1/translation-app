# Translation App

A Flutter Android app for translating typed text and text captured from a camera or gallery image. This repository contains the app UI and supporting mobile code.

## What is in the app

- Text translation and conversation screens
- Camera and gallery text recognition using Google ML Kit
- Speech input and text-to-speech support
- Dictionary, favorites, and translation history flows
- Local storage using SQLite and shared preferences

## Tech

Flutter / Dart, Google ML Kit text recognition, Provider, SQLite, camera, speech-to-text, and text-to-speech. See [pubspec.yaml](pubspec.yaml) for the complete dependency list.

## Run locally

1. Install Flutter with a Dart SDK compatible with the version range in pubspec.yaml.
2. Run flutter pub get.
3. Connect an Android device or start an emulator, then run flutter run.

The repository is a code sample of the mobile implementation. Check external service configuration before using translation or ad-related features in your own environment.
