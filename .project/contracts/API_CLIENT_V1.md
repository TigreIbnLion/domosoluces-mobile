# DOMOSOLUCES API Client V1

Statut: CONTRAT MINIMAL V1 pour demarrage Flutter.
Base URL: configuration d'environnement + /api.
Transport production: HTTPS.
Authentification: Bearer token Laravel Sanctum.

## Authentification
POST /auth/login
Body: email, password, device_name.
Succes: message, token, user.
Erreurs: 401 identifiants, 403 compte desactive, 422 validation, 429 limitation.

Routes authentifiees:
POST /auth/logout
POST /auth/logout-all
GET /auth/me
PUT /auth/profile
PUT /auth/password
GET /auth/sessions
DELETE /auth/sessions/{tokenId}

Le Mobile DOIT utiliser /auth/login. La route historique POST /login n'est pas contractuelle Mobile.

## Client
Toutes les routes suivantes exigent auth:sanctum et role client.

GET /client/kits
GET /client/kits/{kit}
GET /client/kits/{kit}/devices

POST /client/devices/{device}/on
POST /client/devices/{device}/off
GET /client/devices/{device}/status
PUT /client/devices/{device}/config

## Commande equipement
Une reponse HTTP de commande signifie commande acceptee/publiee, pas etat physique confirme.
Le Mobile doit prevoir un etat UI pending puis rafraichir l'etat serveur.
Le champ device.state est l'etat confirme connu du serveur.
Le champ device.status represente la connectivite/sante.

## Erreurs communes
401: token absent/invalide/expire.
403: droit ou role insuffisant.
404: ressource absente/non accessible.
422: validation ou operation impossible.
429: rate limit.
5xx: erreur serveur; ne jamais transformer localement en succes.

## Architecture Mobile autorisee des maintenant
- configuration dev/prod;
- client HTTP central;
- stockage securise du token;
- login/logout/me;
- gestion 401/403/422/429/5xx;
- modeles User/Kit/Device;
- liste kits/devices;
- detail/status device;
- commande on/off avec pending/error/confirmed.

## Routes metier existantes mais non figees dans ce contrat minimal
Subscriptions, payments, consumption, schedules, timers, groups, scenes, automations, notifications et support existent cote serveur mais leurs payloads seront documentes progressivement avant dependance forte du Mobile.

## Regles
Le Mobile ne communique jamais directement avec MQTT, ESP32 ou DB.
Aucun endpoint/payload ne doit etre invente.
Toute incompatibilite remonte dans DEPENDENCIES au LEAD.
Les ajouts compatibles sont autorises; toute rupture V1 exige validation LEAD.
