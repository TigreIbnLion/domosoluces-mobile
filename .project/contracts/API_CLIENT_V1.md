# DOMOSOLUCES API Client V1

Statut: CONTRAT MOBILE V1 ÉTENDU — socle + domaines avancés figés depuis l'implémentation Laravel.
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


## Regles
Le Mobile ne communique jamais directement avec MQTT, ESP32 ou DB.
Aucun endpoint/payload ne doit etre invente.
Toute incompatibilite remonte dans DEPENDENCIES au LEAD.
Les ajouts compatibles sont autorises; toute rupture V1 exige validation LEAD.


# Contrats avancés Mobile V1 — lot 2026-10-04

Toutes les routes ci-dessous sont sous `/api`, exigent `auth:sanctum` et, sauf les routes `/auth/*`, le rôle `client`. Une ressource appartenant à un autre client retourne 403 (ou 404 lorsqu'une requête filtrée par propriétaire ne trouve pas la ressource). Les validations Laravel retournent 422. Les erreurs communes 401/403/404/422/429/5xx définies plus haut restent applicables.

## Profil et sessions

### PUT /auth/profile
Body partiel autorisé :
- `name`: string, max 100.
- `phone`: string, max 20, unique hors utilisateur courant.

Réponse : `{ "message": string, "user": UserV1 }`.
Décision V1 : `email` et `zone` sont **lecture seule** dans ce endpoint. Ils restent exposés par UserV1 mais ne font pas partie du body contractuel de mise à jour. Le Mobile ne doit pas proposer leur modification via cet endpoint.

### PUT /auth/password
Body : `current_password` string requis, `password` string requis min 8, `password_confirmation` requis par la règle `confirmed`.
Réponse : `{ "message": string }`. Un mot de passe actuel incorrect retourne 422. Après succès, les autres tokens sont révoqués ; la session courante est conservée lorsqu'elle est identifiable.

### GET /auth/sessions
Réponse exacte : `{ "sessions": SessionV1[] }`.
SessionV1 :
- `id`: integer.
- `name`: string.
- `last_used_at`: datetime `Y-m-d H:i:s` ou null.
- `created_at`: datetime `Y-m-d H:i:s` ou null.
- `expires_at`: datetime `Y-m-d H:i:s` ou null.

`DELETE /auth/sessions/{tokenId}` révoque uniquement un token appartenant à l'utilisateur courant ; réponse `{ "message": string }`, 404 si absent.
`POST /auth/logout` révoque le token courant. `POST /auth/logout-all` révoque tous les tokens.

## Configuration équipement

### PUT /client/devices/{device}/config
Body partiel, tous les champs sont optionnels :
- `name`: string|null, max 100.
- `display_name`: string|null, max 100.
- `room`: string|null, max 100.
- `icon`: string|null, max 20.
- `color`: string|null, max 30.
- `position`: integer|null, min 0.

Le serveur fusionne les valeurs non-null dans `local_config`. V1 Mobile contractualise l'écriture de ces six clés. La lecture normalisée continue d'utiliser DeviceV1 : `name` est résolu depuis `local_config.name` puis `display_name`; `room` et `icon` sont exposés. `color` et `position` sont acceptés/persistés mais ne sont pas exposés dans DeviceV1 : le Mobile ne doit donc pas dépendre de leur relecture dans V1.
Réponse : `{ "message": string, "device": DeviceV1 }`. Aucun credential MQTT, IP ou MAC n'est exposé.

## Consommation

### GET /client/consumption
Query :
- `period`: `day|week|month|year|custom`, défaut `month`.
- `from`: date, utilisée pour `custom`.
- `to`: date, doit être >= from.
- `kit_id`: UUID|null.
- `device_id`: UUID|null.
- `price_per_kwh`: number 0..100000, défaut 100.
Période maximale : 366 jours, sinon 422. Maximum interne : 10000 mesures.

Réponse :
- `filters`: `{from: YYYY-MM-DD, to: YYYY-MM-DD}`.
- `summary`: `{total_kwh:number, estimated_cost_xof:number, average_power_w:number, peak_power_w:number, records:integer}`.
- `timeline[]`: `{label:string, energy_kwh:number, average_power_w:number}`.
- `by_device[]`: `{device_id:UUID, name:string, type:string|null, kit_name:string|null, energy_kwh:number, share_percent:number, average_power_w:number, peak_power_w:number}`.

### GET /client/kits/{kit}/consumption-summary
Query `period=day|week|month|year`; toute autre valeur est traitée comme `week` par l'implémentation actuelle.
Réponse : `{period:string,total:{kwh:number,cost_xof:number,trend_pct:null,trend_dir:null},per_device:[{device_id:UUID,device_name:string,type:string,total_kwh:number,power_w:number}]}`.

### GET /client/devices/{device}/consumption
Réponse : `{device:{id:UUID,name:string,current_power:number|null,energy_kwh:number|null},history:ConsumptionLog[]}`. La liste est limitée aux 200 dernières mesures. Ce endpoint est lecture seule.

### GET /client/consumption/export
Même filtres que `GET /client/consumption`; réponse fichier CSV UTF-8, pas JSON.

## Programmations / schedules

`GET /client/devices/{device}/schedules` → `{ "schedules": ScheduleV1[] }`.
Création : `POST /client/devices/{device}/schedules`.
Body :
- `name`: string|null max 100.
- `action`: `on|off`.
- `time`: `HH:mm`.
- `days`: tableau d'entiers 0..6.
- `is_active`: boolean|null, défaut true.

Réponse création 201 : `{message:string,schedule:ScheduleV1}`. Attention : l'entrée `action` est `on|off`, mais `ScheduleV1.action` est réellement sérialisé en **boolean** (`true`=ON, `false`=OFF) par le modèle actuel.
ScheduleV1 est la sérialisation Laravel de DeviceSchedule : `id:UUID, device_id:UUID, created_by:UUID, name:string|null, action:boolean, cron_expression:string|null, time_of_day:string, days_of_week:integer[], is_active:boolean, synced_to_device:boolean, last_executed_at:datetime|null, created_at:datetime, updated_at:datetime`.
Suppression : `DELETE /client/schedules/{schedule}` → `{message:string}`. Pas de route UPDATE V1.

## Minuteurs / timers

`GET /client/devices/{device}/timers` → `{timers: TimerV1[]}`, maximum 30, plus récents d'abord.
TimerV1 : `id:UUID, action:on|off, duration_minutes:integer, execute_at:datetime, status:pending|executed|cancelled|failed, executed_at:datetime|null, time_left:string`.

Création : `POST /client/devices/{device}/timers`, body `{action:on|off,duration_min:integer 1..1440}`; réponse 201 `{message:string,timer:object}`.
Annulation : `DELETE /client/timers/{timer}` → `{message:string}`; le statut devient `cancelled`.
Aucune modification d'un timer existant en V1.

## Groupes / pièces logiques

`GET /client/kits/{kit}/groups` → `{groups: GroupV1[]}`.
GroupV1 est la sérialisation Laravel du groupe : `id:UUID,kit_id:UUID,client_id:UUID,name:string,icon:string|null,device_ids:UUID[],created_at:datetime,updated_at:datetime`.

Création `POST /client/kits/{kit}/groups` : `name` requis max100, `icon` nullable max20, `device_ids` tableau UUID nullable ; tous les devices doivent appartenir au kit.
Modification `PUT /client/groups/{group}` : mêmes champs, `name` optionnel mais non-null s'il est fourni.
Suppression `DELETE /client/groups/{group}`.
Ajout device `POST /client/groups/{group}/devices` body `{device_id:UUID}`.
Retrait `DELETE /client/groups/{group}/devices/{device}`.
Exécution `POST /client/groups/{group}/execute` body `{state:on|off}` → `{message:string,sent:integer,failed:integer}`. `sent` signifie publié, jamais état physique confirmé.

## Scènes

`GET /client/kits/{kit}/scenes` → `{scenes: SceneV1[]}`.
SceneV1 : `id:UUID,kit_id:UUID,client_id:UUID,name:string,icon:string|null,actions:Action[],trigger_type:string,trigger_config:object|null,is_active:boolean,last_executed_at:datetime|null,created_at:datetime,updated_at:datetime`.
Action : `device_id:UUID,state:on|off,delay_seconds:integer|null` (0..300).

Création `POST /client/kits/{kit}/scenes` : `name` requis max100, `icon` nullable max20, `actions` tableau non vide, `is_active` boolean nullable. Le serveur force `trigger_type=manual`.
Modification `PUT /client/scenes/{scene}` : mêmes champs modifiables ; toutes les références doivent appartenir au kit.
Suppression `DELETE /client/scenes/{scene}`.
Exécution `POST /client/scenes/{scene}/execute` → `{message:string,sent:integer,failed:integer}`; scène inactive → 422. `sent` ne confirme pas les états physiques.

## Automatisations

`GET /client/automations` → `{automations: AutomationV1[]}`.
AutomationV1 : `id:UUID,client_id:UUID,kit_id:UUID,name:string,icon:string|null,trigger_type:device_state|time_window,condition_config:object,action_type:device|scene|group,action_target_id:UUID,action_state:on|off|null,is_active:boolean,cooldown_minutes:integer|null,last_executed_at:datetime|null,created_at:datetime,updated_at:datetime`.

Création `POST /client/automations`, modification complète `PUT /client/automations/{automation}` :
- `kit_id` UUID requis, `name` requis max100, `icon` nullable max20.
- `trigger_type`: `device_state|time_window`.
- `condition_config` objet requis. Pour device_state : `device_id` UUID + `state:on|off`. Pour time_window : `start_time/end_time HH:mm`.
- `action_type`: `device|scene|group`; `action_target_id` UUID requis ; `action_state:on|off` requis pour device/group, nullable pour scene.
- `is_active` boolean nullable ; `cooldown_minutes` integer|null 1..1440.
Les références hors kit retournent 422.
Toggle : `PUT /client/automations/{automation}/toggle` → `{message:string,automation:AutomationV1}`.
Suppression : `DELETE /client/automations/{automation}`.

## Notifications / alertes

### GET /client/notifications
Query : `severity=info|warning|critical`, `type:string<=60`, `status=all|read|unread`, `search:string<=100`, `per_page:1..100` défaut20.
Réponse : `{alerts: LaravelPaginator<AlertV1>, unread_count:integer}`.
AlertV1 : `id:UUID,type:string,title:string,message:string,severity:info|warning|critical,is_read:boolean,time_ago:string,created_at:datetime,device_id:UUID|null,kit_id:UUID|null,metadata:object|array|null`.
Le paginator Laravel contient notamment `current_page,data,first_page_url,from,last_page,last_page_url,links,next_page_url,path,per_page,prev_page_url,to,total`.

Actions : `PUT /client/notifications/{alert}/read`, `PUT /client/notifications/read-all`, `DELETE /client/notifications/{alert}`, `DELETE /client/notifications` (supprime les lues).

### Préférences
`GET /client/notification-preferences` → `{preferences: PreferenceV1}`.
`PUT /client/notification-preferences` accepte des booléens optionnels :
`email_enabled,sms_enabled,push_enabled,in_app_enabled,notify_payment_success,notify_payment_failed,notify_subscription_expiring,notify_subscription_expired,notify_subscription_renewed,notify_device_offline,notify_high_consumption,notify_ticket_reply`.
Réponse update : `{message:string,preferences:PreferenceV1}`.

## Support / tickets

`GET /client/tickets` → `{tickets: LaravelPaginator<TicketV1>,stats:{open:integer,resolved:integer}}`, pagination fixe 15.
TicketV1 : `id:UUID,ticket_number:string,subject:string,category:string,category_label:string,priority:string,priority_label:string,status:string,status_label:string,client:object|null,kit:{name:string,serial:string}|null,assigned_to:string|null,assigned_to_id:UUID|null,response_time:mixed,resolution_time:mixed,satisfaction:integer|null,last_message:{body:string,sender:string|null,time_ago:string}|null,created_at:datetime,updated_at:datetime`.
Détail `GET /client/tickets/{ticket}` → `{ticket:TicketV1}` avec `messages: MessageV1[]`.
MessageV1 : `id:UUID,body:string,sender_name:string|null,sender_role:string|null,is_from_client:boolean,is_internal_note:boolean,is_read:boolean,attachments:array,time_ago:string,created_at:datetime`. Pour un client, `messages` contient **uniquement les messages publics** (`is_internal_note=false`) ; les notes internes support ne font jamais partie du contrat Mobile.

Création `POST /client/tickets` : `subject` requis max150, `description` requis max2000, `category=paiement|abonnement|equipement_offline|equipement_defectueux|application|autre`, `kit_id` UUID nullable, `priority=low|medium|high` optionnelle. Réponse 201 `{message:string,ticket:TicketV1}`.
Réponse client `POST /client/tickets/{ticket}/messages` body `{body:string max3000}`; ticket résolu →422.
Évaluation `POST /client/tickets/{ticket}/rate` body `{score:integer 1..5,comment:string|null max500}`; ticket non résolu →422.
Le Mobile client n'a pas de route de suppression/fermeture directe de ticket.

## Abonnements et paiements

Ces routes sont exposables au Mobile V1 car elles sont déjà protégées par `auth:sanctum + role:client` et vérifient la propriété des ressources.

`GET /client/plans` → `{plans: PlanV1[]}`. PlanV1 contient exactement : `id:UUID,name:string,slug:string,price:number|string,formatted_price:string,quota_total:integer|null,max_extra_devices:integer|null,is_custom:boolean,trial_days:integer|null,description:string|null,features:array`.
`GET /client/subscriptions` → `{subscriptions: SubscriptionV1[]}`.
`GET /client/subscriptions/{sub}` → `{subscription: SubscriptionV1Detailed}`.
SubscriptionV1 : `id:UUID,kit:{id:UUID,name:string|null,serial:string}|null,plan:{id:UUID,name:string,slug:string,price:number|string,formatted_price:string}|null,status:string,pause_status:string,is_paused:boolean,starts_at:date|null,ends_at:date|null,days_remaining:integer,is_expiring:boolean,auto_renew:boolean,dunning_count:integer`.
Le détail ajoute `payments[]`, `upgrades[]`, `pauses[]` tels que formatés par le serveur.

Renouvellement `POST /client/subscriptions/{sub}/renew` : `payment_method=mobile_money|orange_money|wave|visa|mastercard`, `phone` requis pour mobile_money/orange_money/wave, `promo_code` nullable max30. Réponse succès : `{message,amount,transaction_id,payment_url:string|null}`; échec initiation →422.
Calcul changement : `GET /client/subscriptions/{sub}/calculate-upgrade?new_plan_id=UUID`.
Upgrade : `POST /client/subscriptions/{sub}/upgrade` avec `new_plan_id`, méthode de paiement selon coût, `phone` nullable.
Pause : `POST /client/subscriptions/{sub}/pause` body `{reason?:string<=255,resume_at?:date future}`.
Reprise : `POST /client/subscriptions/{sub}/resume`.
Résiliation : `POST /client/subscriptions/{sub}/cancel` body `{reason?:string<=500}`.
Auto-renouvellement : `PUT /client/subscriptions/{sub}/toggle-autorenew`.

`GET /client/payments` → `{payments:LaravelPaginator<PaymentSummaryV1>,summary:{total_paid:number,last_payment:datetime|null}}`.
PaymentSummaryV1 : `id:UUID,amount:number|string,currency:string,method:string,status:string,transaction_id:string,plan:string|null,paid_at:datetime|null,created_at:datetime`.
`GET /client/payments/{payment}` → `{payment:PaymentV1}` où PaymentV1 ajoute `provider:string|null`.
`GET /client/payments/{payment}/status` → `{id:UUID,status:string,transaction_id:string,paid_at:datetime|null}`.
Les statuts de paiement ne sont pas contractualisés comme enum fermé tant que le modèle/provider ne les contraint pas tous ; le Mobile doit au minimum gérer `pending`, `completed`, `failed` et tolérer une valeur inconnue.

## Règles d'autorité IoT pour les fonctions avancées
Les exécutions de groupe, scène, timer, schedule ou automation qui publient des commandes ne constituent jamais une confirmation de `device.state`. Le Mobile doit utiliser Device Status V1 pour afficher l'état physique confirmé. Le contrat IOT_V1 reste inchangé.


# Projection IoT Capabilities V2 — extension additive du Client V1

DeviceV1 reste inchangé. Les clients ne déduisent **jamais** une capability depuis `type`, `name`, `icon`, le modèle matériel ou Keyestudio.

### GET /client/devices/{device}/capabilities
Réponse:
- `device_id: UUID`
- `schema_version: "2.0"`
- `capabilities: CapabilityV2[]`
- `values: object` indexé par capability_id; chaque valeur confirmée contient `value`, `origin`, `confirmed_at`.
- `recovery_policy: object` indexé par capability_id.

`CapabilityV2` suit IOT_V2: `id,kind,semantic,state,commands,telemetry,availability,metadata?`.
Un device V1 sans manifeste retourne `capabilities:[]`, sans casser DeviceV1.

### POST /client/devices/{device}/capability-commands
Body exact: `{capability_id:string,command:string,value:mixed}`.
Le serveur vérifie ownership, online/active/MODE_SMART, présence de la capability, `availability.commandable`, commande déclarée et schéma de valeur.
Succès HTTP 202: `{message:string,command_id:UUID,status:"sent"}`.
Ce succès signifie **publié/en attente**, jamais état confirmé. Le Mobile rafraîchit `GET .../capabilities` ou attend un mécanisme de refresh API; il ne modifie pas localement la valeur confirmée.
422: capability/commande/valeur indisponible ou invalide.

### GET /client/devices/{device}/events
Query optionnelle: `capability_id:string`, `per_page:1..100` défaut 20.
Réponse: `{events: LaravelPaginator<DeviceEventV2>}`.
Event: `id,device_id,capability_id,event_type,value,unit,source,observed_at,metadata,created_at,updated_at`.
La présence d'un event n'implique ni alerte ni commande.

### POST /client/pairing/claim
Body: `pairing_id:UUID,kit_serial:string,device_uid:string,pairing_token:string`.
Succès: `{message,kit_id,device_id,kit_serial,device_uid}`.
Le token est éphémère et à usage unique. Le Mobile ne transmet **aucun SSID/mot de passe Wi-Fi** à Laravel. Un kit appartenant déjà à un autre client est refusé.

### Articulation DeviceV1 / CapabilitiesV2
- `status`: santé/connectivité globale, inchangé.
- `state:on|off`: état binaire global V1, inchangé et conservé pour compatibilité.
- `mode`: autorité métier serveur, inchangé.
- `capabilities/values`: fonctions avancées et leurs valeurs confirmées.
Une capability V2 ne doit pas être inventée lorsque `capabilities[]` ne la déclare pas.

### Sécurité UX
Les capabilities `gas` et `water` issues du prototype ne doivent jamais être libellées comme dispositifs certifiés de sécurité des personnes. Les alertes métier sont distinctes des événements capteur bruts.
