# Recette MOBILE

Le client Flutter ne contient aucun secret de recette et ne communique jamais directement avec MQTT.

L'URL API est injectée au build/runtime Flutter via les dart-defines:

```bash
flutter run --dart-define=APP_ENV=staging --dart-define=API_ORIGIN=https://<api-recette>
```

`API_ORIGIN` est l'origine HTTPS du serveur recette, sans obligation d'ajouter `/api`: le client ajoute exactement un suffixe `/api`.

Les identifiants client de recette ne doivent pas être commités. Ils sont saisis dans l'écran de connexion et le token Sanctum est stocké via `flutter_secure_storage`.

Parcours à valider: connexion -> kits -> équipements -> détail -> ON/OFF -> pending -> polling `/status` -> état physique confirmé.
