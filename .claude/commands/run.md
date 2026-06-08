# /run — Start the DoDa app

Runs the Flutter app on the first available device.

```bash
cd /mnt/c/Herve/doda && flutter pub get && flutter run
```

If no device is connected, list available emulators with:
```bash
flutter devices
```

Then start a specific one:
```bash
flutter run -d <device-id>
```

Hot reload is available once running: press `r` in the terminal.
Hot restart: `R`.
