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

### GET /auth/me — schema V1 exact
Wrapper: aucun wrapper additionnel.

Champs:
- id: UUID
- name: string
- email: string
- phone: string|null
- role: string
- zone: string|null
- is_active: boolean
- has_2fa: boolean
- created_at: date YYYY-MM-DD
- unread_alerts: integer pour un client
- sites: tableau charge par cet endpoint; chaque entree contient exactement id, name, city

Aucun password, token ou secret 2FA n'est retourne.

## Client
Toutes les routes suivantes exigent auth:sanctum et role client.

GET /client/kits
GET /client/kits/{kit}
GET /client/kits/{kit}/devices

POST /client/devices/{device}/on
POST /client/devices/{device}/off
GET /client/devices/{device}/status
PUT /client/devices/{device}/config

## Schemas JSON Mobile V1

### Kit V1
Champs exacts:
- id: UUID
- serial_number: string
- name: string|null
- site_label: string|null
- type: string|null
- status: string
- installed_at: ISO-8601|null
- activated_at: ISO-8601|null
- devices_count: integer

GET /client/kits:
`{ "kits": [KitV1, ...] }`

GET /client/kits/{kit}:
`{ "kit": KitV1, "devices": [DeviceV1, ...] }`

GET /client/kits/{kit}/devices:
`{ "kit": KitV1, "devices": [DeviceV1, ...] }`

### Device V1
Champs exacts:
- id: UUID
- kit_id: UUID
- device_uid: string
- name: string|null
- room: string|null
- icon: string|null
- type: prise|interrupteur|dismatique|relais
- status: online|offline|error|updating
- state: on|off
- mode: provision|smart|normal|error
- is_active: boolean
- is_leader: boolean
- firmware_version: string|null
- last_seen_at: ISO-8601|null
- current_power: number|null, watts
- energy_kwh: number|null, kWh

Les champs name, room et icon proviennent de la configuration locale serveur. Aucun credential MQTT, IP, MAC ou metadata interne n'est contractuel Mobile.

### Device Status V1
GET /client/devices/{device}/status:
`{ "device": DeviceV1 }`

device.status represente exclusivement la connectivite/sante.
device.state represente exclusivement le dernier etat physique confirme connu du serveur.
L'envoi d'une commande HTTP/MQTT ne modifie jamais device.state; seule une confirmation equipment valide (ACK/state) peut le faire.

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
