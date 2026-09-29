# DOMOSOLUCES Mobile

Application mobile officielle DOMOSOLUCES.

## Stack cible
Flutter / Dart.

## Etat
Initialisation contrôlée par le LEAD. Le code applicatif sera créé sur la branche develop après validation du contrat API V1.

## Règles
- Laravel API est la source de vérité métier.
- Le mobile ne communique jamais directement avec MQTT ni avec les équipements.
- Aucun endpoint ou format métier ne doit être inventé côté mobile.
- Aucun secret serveur/device dans l'application.
