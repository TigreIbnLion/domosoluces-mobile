# Etat d'intégration

Date de référence : 2026-09-29

## WEB_API
Statut : INTEGRE / VALIDE
Base : Laravel 12, Vue/Inertia, Sanctum, MQTT, Docker, Mosquitto, queue, scheduler, listener.
Branche develop : lot WEB_API integre via PR #2, commit d'integration 519dc71676fab94c3daa5c67660215294b0de5cf.
Validation :
- migrate:fresh SQLite : PASS
- PHPUnit cible : 0 echec, 105 assertions
- 20 warnings file_get_contents lies au test harness
- statut : PASS WITH TEST HARNESS WARNINGS
P0 restant : recette MQTT/serveur/équipement réelle, sécurité device/MQTT et E2E complet.
Runner E2E serveur : INTEGRE au lot validé LEAD (`domosoluces:e2e-iot`), données isolées et nettoyage automatique, double garde-fou pour le serveur recette historiquement `APP_ENV=production`.
Recette runtime : A EXECUTER après déploiement de develop sur le serveur recette ; aucun PASS E2E runtime n'est déclaré avant cette exécution.

## MOBILE
Statut : INITIALISE / DEVELOPPEMENT EN COURS
Repository : TigreIbnLion/domosoluces-mobile.
Branche develop : b592c70ec8ab1b28d87e11c11e4d980ec42c0387.
Contrat API Client V1 synchronisé.
Présent : client HTTP, stockage token, authentification, modèles Client/Kit/Device, commandes ON/OFF, gestion pending/error et tests.
Prochaine validation : connexion réelle à l'API DEV puis flux kits -> devices -> détail/status -> ON/OFF -> confirmation.

## EQUIPEMENT
Statut : INITIALISE / DEVELOPPEMENT FIRMWARE EN COURS
Repository : TigreIbnLion/domosoluces-equipement.
Branche develop : 9e096be091531957380cf388dc51eff35850adee.
Contrat IoT V1 synchronisé.
Présent : abstraction HardwareAdapter, KeyestudioAdapter, MQTT, heartbeat, state, telemetry, ACK, idempotence et récupération MQTT.
Prochaine validation : flash matériel, connexion au broker DEV, réception command, publication ACK/state/heartbeat et test réel avec WEB_API.

## PRODUCTION
La branche production du Web reste séparée. Aucun changement de develop ne doit la déclencher directement.

## PROCHAINE ETAPE LEAD
1. Disposer d'un environnement DEV accessible au Web/API et au broker MQTT.
2. Vérifier les paramètres de connexion sans publier de secrets dans Git.
3. Connecter un équipement prototype au broker DEV.
4. Valider le flux E2E Web/API -> MQTT -> équipement -> ACK/state -> API -> Mobile.
5. Corriger uniquement les écarts observés, puis figer la recette E2E.
