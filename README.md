# chatapp
ChatApp Studiengang Mobile UX

## Flutter
A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Installation
Flutter installiert in der Regel Dart language mit : https://dart.dev/get-dart

Install Flutter: 

für macos mit Homebrew: https://formulae.brew.sh/

oder auf der offizieln flutter seite: https://docs.flutter.dev/get-started/install

### Nach der Installation:
flutter doctor 
Falls Fehler auftreten den schritten von flutter doctor folgen

Um einen Emulator für das Betriebssystem wird 

Installieren von Android Emulatoren: Android Studio 

Installieren von Ios Emulatoren: Xcode

## Starten einer Flutter App für die Entwicklung

Erstellen einer flutter app mit dem OrdnerNamen chat-app:
flutter create chat-app

Auflisten der zur Verfügung stehender Emulatoren:
flutter emulators
Ausgabe: 
Id
Phone_API_35

Die jeweilige emulator Id die gestartet werden will auswählen:

flutter emulator --launch Phone_API_35 

Emulator sollte starten

flutter run

Die flutter App sollte auf dem Emulator starten

## Git Pull Request

Jedes neue Feature eine neue Branch erstellen:
git checkout -b update-readme-pullrequest 

Branch veröffentlichen und Änderungen machen danach Commit

Erstellen eines Pull Request: 
git push origin update-readme-pullrequest

