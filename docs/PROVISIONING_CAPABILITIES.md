# Architecture Mobile — Provisioning local et Capabilities

Statut : PREPARATION UX / AUCUN PROTOCOLE INVENTE.

## Principes non négociables

- Le Mobile continue d'utiliser exclusivement API_CLIENT_V1 pour les fonctions serveur déjà figées.
- Le provisioning est une exception locale explicite : téléphone ↔ équipement en mode PROVISION.
- Le mot de passe Wi-Fi saisi par l'utilisateur ne doit jamais être envoyé à Laravel, journalisé, persisté dans les modèles API ou inclus dans une télémétrie.
- Aucun endpoint local, transport (BLE/SoftAP/etc.), payload, secret, preuve cryptographique ou mécanisme d'association n'est défini ici : ils restent bloqués jusqu'au contrat LEAD/WEB_API/EQUIPEMENT.
- L'UI fonctionnelle finale doit être pilotée par les capabilities contractuelles retournées par l'API. Aucun nouveau comportement ne doit être déduit de `device.type`.

## Parcours UX préparé

Machine d'états conceptuelle, indépendante du transport :
1. Ajouter équipement.
2. Détecter / identifier l'équipement.
3. Établir une session locale avec l'équipement en mode PROVISION.
4. Demander à l'équipement son scan Wi-Fi.
5. Sélectionner le réseau.
6. Saisir les identifiants Wi-Fi dans un écran local.
7. Transférer localement les identifiants au device.
8. Attendre le reboot.
9. Attendre la connexion du device.
10. Effectuer l'association / validation serveur selon le futur contrat.
11. Attendre que l'API confirme l'équipement ONLINE.

Chaque étape doit avoir loading, timeout, retry, annulation et erreur explicite. Une progression locale ne doit jamais être présentée comme une association serveur réussie avant confirmation API.

## Frontières d'architecture prévues

Le futur code devra séparer :
- `ProvisioningCoordinator` : machine d'états UX, sans détails de transport.
- `LocalProvisioningTransport` : interface abstraite de découverte/session locale/scan/transfert/reboot; implémentation interdite avant contrat.
- `ProvisioningSecret` : valeur éphémère pour le mot de passe Wi-Fi, jamais sérialisée vers ApiClient.
- `ServerPairingRepository` : association/validation via Laravel uniquement après publication du contrat.
- `DeviceCapabilities` / policy UI : modèle issu du futur schéma API, source de vérité pour l'affichage des actions.

## Capabilities

Le modèle définitif reste volontairement absent. Le contrat doit préciser au minimum le schéma, les types, le versionnement, la compatibilité inconnue, les fonctionnalités/commandes supportées et la relation avec les permissions/états. Jusqu'à publication, le Mobile conserve les fonctions déjà contractualisées et ne crée aucune commande IoT supplémentaire.

## Dépendances

Voir `.project/DEPENDENCIES.md` :
- contrat complet de provisioning local et mécanisme cryptographique;
- contrat API des capabilities et règles de pilotage UX.
