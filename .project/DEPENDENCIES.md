# DEPENDENCIES

## MOBILE -> WEB_API
Besoin: figer les schemas de reponse JSON de GET /client/kits, GET /client/kits/{kit}, GET /client/kits/{kit}/devices et GET /client/devices/{device}/status, notamment les identifiants contractuels a reutiliser dans les URLs.
Motif: permettre la navigation Kit -> Equipements -> Detail sans inventer de champs id/uid/name ni de wrappers de reponse.
Urgence: HAUTE
Statut: A TRAITER PAR LEAD

## MOBILE -> WEB_API
Besoin: confirmer le format exact de GET /auth/me (objet user direct ou enveloppe user) et les champs User V1 affichables.
Motif: typer le profil et finaliser le bootstrap de session sans hypothese de payload.
Urgence: MOYENNE
Statut: A TRAITER PAR LEAD
