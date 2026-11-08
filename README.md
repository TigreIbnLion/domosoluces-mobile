# DOMOSOLUCES Mobile

Application Flutter officielle DOMOSOLUCES.

## API HTTPS

L'application utilise par défaut l'environnement `production` et l'origine `https://domosoluces.ci`.
Le client ajoute automatiquement `/api`, soit `https://domosoluces.ci/api`.
La configuration production refuse une origine HTTP.

Pour compiler un APK de test pointant vers le domaine officiel :

```powershell
C:\flutter\bin\flutter.bat build apk --release --dart-define=APP_ENV=production --dart-define=API_ORIGIN=https://domosoluces.ci
```

APK : `build/app/outputs/flutter-apk/app-release.apk`.

Pour tester contre un serveur local Android Emulator :

```powershell
C:\flutter\bin\flutter.bat run --dart-define=APP_ENV=dev --dart-define=API_ORIGIN=http://10.0.2.2:8000
```

L'URL HTTPS, le certificat TLS et les routes Laravel doivent être vérifiés sur le serveur avant distribution. La compilation n'atteste pas de la disponibilité de l'API. Le package Android et la signature officielle doivent être finalisés avant publication.

## Architecture

Laravel API est la source de vérité métier. Aucun accès direct à MQTT ou à la base de données. Aucun secret serveur ou équipement dans l'application.
