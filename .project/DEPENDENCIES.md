# Dépendances inter-blocs

Format : date | demandeur | fournisseur | besoin | urgence | statut

## Ouvertes
- 2026-09-29 | EQUIPEMENT | WEB_API | Valider le contrat MQTT/ACK/telemetry/heartbeat V1 côté broker et serveur DEV avec un équipement réel | CRITIQUE | A TRAITER PAR LEAD
- 2026-09-29 | WEB_API | EQUIPEMENT | Définir capacités exactes du prototype Keyestudio et mapping vers matériel final | HAUTE | A TRAITER
- 2026-09-29 | EQUIPEMENT | LEAD | Définir provisioning et frontière de confidentialité usine | CRITIQUE | EN COURS LEAD
- 2026-09-29 | LEAD | WEB_API | Préparer un environnement DEV accessible pour API et broker MQTT, sans secrets dans Git | CRITIQUE | A TRAITER PAR LEAD

## Résolues
- 2026-10-04 | MOBILE | LEAD/WEB_API | Figer contrats API Mobile avancés : sessions, config équipement, consommation, schedules, timers, groupes, scènes, automatisations, notifications/préférences, support, abonnements/paiements | HAUTE | RESOLU — API_CLIENT_V1 étendu et synchronisé depuis WEB_API; email/zone lecture seule
- 2026-09-29 | MOBILE | WEB_API | Figer API client V1 : schémas /auth/me, kits, devices et status pour Flutter | HAUTE | RESOLU — publié dans .project/contracts/API_CLIENT_V1.md
- 2026-09-29 | EQUIPEMENT | WEB_API | Figer contrat IoT/ACK/telemetry/heartbeat V1 | CRITIQUE | RESOLU — publié dans .project/contracts/IOT_V1.md
