# API Design, protocoles RESTful & spécification OpenAPI 3.0

Notions vues dans ce projet : ce que c'est, à quoi ça sert, et une analogie tirée de **Final Fantasy VII** pour s'en souvenir.

## L'univers des analogies

Toutes les analogies utilisent le même décor, pour rester cohérentes d'une notion à l'autre.

| Notion               | Image FFVII                                                            |
| -------------------- | ---------------------------------------------------------------------- |
| Le système (l'API)   | **Midgar**, la ville fortifiée, avec ses portes d'entrée               |
| Le contrat OpenAPI   | Le **briefing de mission** au 7th Heaven, avant de partir              |
| Le webhook           | Un contact qui t'**appelle** quand le job est fait                     |
| Une ressource        | Un **Chocobo** de l'élevage                                            |
| Les verbes HTTP      | Ce qu'on fait **avec** un Chocobo (le monter, le nourrir, le relâcher) |
| `components`         | La **réserve de matérias** : on forge une fois, on équipe partout      |
| JSON Schema          | Le **contrôle d'accès** du QG de la Shinra                             |
| Spectral (le linter) | La capacité **Analyse**, qui révèle les faiblesses sans attaquer       |

---

## 1. API et contrat

**API (Application Programming Interface)** : l'ensemble des « portes » par lesquelles le monde extérieur peut parler à une application. Chaque porte précise ce qu'on peut demander, sous quelle forme, et ce qu'on obtient en retour.

> **Analogie :** les portes de Midgar. On n'entre pas où l'on veut dans la ville : on passe par une porte précise, avec des règles précises, et l'on reçoit une réponse.

**Spec-Driven Development (API-First)** : on écrit d'abord le **contrat** de l'API (le document OpenAPI), puis chaque équipe construit à partir de lui.

**Code-First** (l'approche inverse) : on code d'abord, puis on génère la documentation à partir du code. La documentation devient alors une réflexion après coup.

> **Analogie :** le briefing de mission au 7th Heaven. Avant de partir, toute l'équipe (Barret, Tifa, Cloud…) valide le même plan : quel réacteur, à quelle heure, par quelle entrée. Avec Code-First, on fonce vers le réacteur, puis on dessine la carte d'après ce qui s'est passé.

**Pourquoi un contrat unique ?** Si la documentation dit `orderId` de type UUID et que le Back-end code `order_id` en entier, l'application cliente plante en production.

> **Analogie :** Barret annonce « réacteur n°1 » et Cloud a compris « réacteur n°5 ». Chacun est convaincu d'avoir raison, et la mission échoue. Le contrat écrit évite ce malentendu.

**Ce que le contrat permet de générer :**

- des SDK clients ;
- des bouchons (mocks) pour les tests d'intégration ;
- la configuration d'un pare-feu applicatif (WAF) qui bloque les payloads mal formés.

> **Analogie :** le **simulateur de combat** de la Shinra. Les mocks sont des adversaires d'entraînement : on teste son équipe sans risquer le vrai combat. Le WAF, lui, est la garde postée aux portes de Midgar.

**Shift-left security** : détecter les problèmes le plus tôt possible dans le cycle de développement, ici dès l'écriture du contrat.

> **Analogie :** repérer le piège pendant la reconnaissance, avant d'entrer dans le réacteur, plutôt qu'après l'explosion.

---

## 2. Webhook

**Webhook** : une route de notre API que **l'autre système appelle lui-même** quand un événement se produit, au lieu que nous lui demandions sans cesse où il en est.

> **Analogie :** on laisse son numéro à un contact d'AVALANCHE. Il appelle dès que la mission est terminée, au lieu qu'on l'appelle toutes les dix minutes pour savoir si c'est fini.

Dans ce projet, c'est la banque qui appelle MegaShop-B2B pour annoncer qu'un paiement a réussi ou échoué.

---

## 3. Architecture REST

**REST** est un style d'architecture pour les API web, fondé sur trois idées.

### 3.1 Ressources et verbes HTTP

- **Ressource** : une chose du domaine métier, nommée par un **nom** (`/payments`, `/orders`). L'URL désigne la ressource.
- **Verbe HTTP** : l'**action** que l'on fait sur la ressource.

> **Analogie :** les Chocobos de l'élevage. Le **nom**, c'est le Chocobo. Les **verbes**, c'est ce qu'on en fait : l'observer, l'ajouter à l'élevage, le nourrir, le relâcher.

| Verbe    | Sens                                    | Avec un Chocobo                                                     |
| -------- | --------------------------------------- | ------------------------------------------------------------------- |
| `GET`    | lire                                    | observer ses caractéristiques                                       |
| `POST`   | créer, ou envoyer une donnée au serveur | ajouter un nouveau Chocobo à l'élevage                              |
| `PUT`    | remplacer                               | échanger un Chocobo contre un autre                                 |
| `PATCH`  | modifier en partie                      | lui donner à manger pour faire progresser une seule caractéristique |
| `DELETE` | supprimer                               | le relâcher dans la nature                                          |

**Anti-pattern : mettre un verbe dans l'URL.** `POST /api/v1/updatePaymentStatus` est mauvais pour trois raisons :

- `update` est un verbe d'action, déjà porté par la méthode HTTP, donc c'est redondant ;
- le camelCase n'est pas la convention des URLs REST ;
- `/api/v1` double le `/v1` déjà présent dans `servers.url`.

> **Analogie :** on ne nomme pas l'enclos « nourrirLeChocobo ». L'enclos s'appelle `/chocobos`, et c'est le **geste** (le verbe HTTP) qui dit si l'on nourrit, déplace ou relâche.

Ce style, où l'URL nomme une action, relève du paradigme **RPC**, pas de REST.

Route corrigée : `POST /payments/webhook`.

### 3.2 Stateless

**Stateless** (sans état) : chaque requête contient **toutes** les informations nécessaires. Le serveur ne garde pas en mémoire ce qui s'est passé avant.

> **Analogie :** un garde de la Shinra qui n'a aucune mémoire. Même si tu es déjà passé dix fois, tu dois montrer ton badge complet à chaque passage.

### 3.3 Codes de statut HTTP

Le code résume le résultat de la requête.

| Famille | Sens                                     | Dans FFVII                      |
| ------- | ---------------------------------------- | ------------------------------- |
| `2xx`   | succès                                   | mission accomplie               |
| `4xx`   | erreur du **client** (il a mal demandé)  | l'équipe s'est trompée de plan  |
| `5xx`   | erreur du **serveur** (il a mal répondu) | le réacteur explose de son côté |

| Code                        | Sens                                  | Exemple dans ce projet                 |
| --------------------------- | ------------------------------------- | -------------------------------------- |
| `200 OK`                    | succès, avec un corps de réponse      |                                        |
| `204 No Content`            | succès, **volontairement sans corps** | webhook accepté, `DELETE` réussi       |
| `400 Bad Request`           | la requête est invalide               | payload qui ne respecte pas le contrat |
| `404 Not Found`             | la ressource n'existe pas             |                                        |
| `500 Internal Server Error` | le serveur a planté                   |                                        |

> **Analogie pour `204` :** on rend le message au contact, il hoche la tête et repart sans un mot. La mission est faite, il n'y a rien à ajouter.
>
> **Pour `400` :** le garde refuse un badge illisible. **Pour `404` :** on cherche un coffre à un endroit où il n'existe pas.

---

## 4. Anatomie d'un document OpenAPI 3.0

**OpenAPI** : un format (YAML ou JSON) pour décrire une API REST de façon lisible par les humains **et** par les machines.

> **Analogie :** le dossier de mission complet, que tout le monde sait lire.

| Section      | Rôle                                                                         | Dans le dossier de mission      |
| ------------ | ---------------------------------------------------------------------------- | ------------------------------- |
| `openapi`    | version de la spécification utilisée (`3.0.3`)                               | le format du dossier            |
| `info`       | identité de l'API : titre, version, description                              | la page de garde de l'opération |
| `servers`    | URL racine du serveur (ici `https://api.megashop-b2b.com/v1`)                | l'adresse du QG                 |
| `paths`      | les routes, et pour chacune ses verbes, son corps de requête et ses réponses | les itinéraires dans Midgar     |
| `components` | les éléments **réutilisables** : schémas, paramètres, en-têtes, réponses…    | la réserve de matérias          |

### `components` et `$ref`

**`components`** centralise les définitions réutilisables. On les définit **une seule fois**.

**`$ref`** : un renvoi vers une définition de `components`. Exemple : `$ref: '#/components/schemas/WebhookPayload'`.

> **Analogie :** la réserve de matérias. On forge la matéria **Soin** une seule fois, puis chaque personnage qui en a besoin y fait référence, au lieu de la reforger à chaque fois. `$ref` est l'étiquette qui dit « prends celle-là ».

**DRY (Don't Repeat Yourself)** : ne jamais dupliquer une définition. Décrire un schéma « inline » sous `paths` rend le fichier illisible et empêche de réutiliser le schéma, ou d'en générer des classes dans le code.

### Où vont les choses

- L'URL racine du serveur va dans `servers`, pas dans `components`.
- La documentation destinée aux lecteurs va dans `description` et `summary`.
- Le SSL et la répartition de charge relèvent de l'infrastructure, pas du contrat.

### Pièges de syntaxe

- **Indentation YAML** : `post:` est un **enfant** du chemin (`/payments/webhook:`). Au même niveau, YAML le lirait comme un autre chemin.
- **Type de média** : c'est `application/json`, sans « s ». Une faute n'est pas une erreur YAML, mais le contrat décrit alors un format que personne n'envoie.
- **Codes de réponse** : on les met entre guillemets (`"204"`) car ce sont des clés de type chaîne.

---

## 5. JSON Schema : typage strict

**JSON Schema** : un vocabulaire pour décrire précisément la forme d'un JSON valide. Il sert à **refuser** automatiquement tout ce qui sort du contrat.

> **Analogie :** le contrôle d'accès du QG de la Shinra. Le garde dispose d'une fiche de règles précise et ne laisse passer que ce qui y correspond.

| Mot-clé                       | Rôle                                              | Analogie QG Shinra                                                         | Exemple                     |
| ----------------------------- | ------------------------------------------------- | -------------------------------------------------------------------------- | --------------------------- |
| `type`                        | le type de base (`object`, `string`…)             | la nature de la pièce présentée (un badge, pas un ticket)                  | `type: string`              |
| `required`                    | liste des champs **obligatoires**                 | les mentions obligatoires du formulaire d'accès                            | `required: [orderId, ...]`  |
| `format`                      | précise la forme d'une `string`                   | le gabarit d'un badge officiel                                             | `format: uuid`              |
| `enum`                        | liste fermée de valeurs autorisées                | les grades de SOLDAT : 1ère, 2ème ou 3ème classe, rien d'autre             | `enum: [SUCCESS, FAILED]`   |
| `pattern`                     | expression régulière que la valeur doit respecter | un matricule au format imposé : préfixe, tiret, chiffres                   | `pattern: '^TXN-[0-9]{8}$'` |
| `additionalProperties: false` | interdit tout champ non déclaré                   | la liste des visiteurs autorisés : si ton nom n'y est pas, tu n'entres pas |                             |

### À savoir

- **`required`** : par défaut, toutes les propriétés sont **optionnelles**. Sans `required`, un corps vide `{}` serait valide, comme si le garde laissait entrer quelqu'un sans aucun badge.
- **`format: uuid`** : le `type` reste `string`. Le UUID se précise avec `format`, pas avec `type`.
- **`enum`** : la casse compte. `success` est refusé si seul `SUCCESS` est autorisé.
- **`pattern`** : `^` ancre le début et `$` ancre la fin de la chaîne. Sans eux, `abc-TXN-12345678-xyz` serait accepté, car le motif apparaît quelque part dedans. C'est un garde qui vérifierait seulement qu'un bout du matricule est correct.
- **`additionalProperties: false`** : bloque les champs « espions » qu'un client malveillant ou mal configuré pourrait ajouter, comme un intrus qui tenterait de se glisser derrière un visiteur autorisé.

---

## 6. Validation : linter et aperçu

**Linter** : un outil qui analyse un fichier et signale les erreurs et les mauvaises pratiques, sans l'exécuter.

> **Analogie :** la capacité **Analyse**. Elle révèle les faiblesses d'un ennemi sans l'attaquer. Le linter fait la même chose avec ton fichier : il le lit et te dit où ça risque de casser, sans rien lancer.

**Spectral** : le linter de référence pour OpenAPI.

```bash
spectral lint api/openapi.yaml
```

- Une **error** est un problème de structure : indentation, nœud mal placé, `$ref` cassé. C'est une faille critique dans le plan.
- Un **warning** est une mauvaise pratique : description manquante, `operationId` absent… C'est un point faible à surveiller.
- Spectral 6 n'a **aucune règle intégrée**. Il faut un fichier `.spectral.yaml` pour lui indiquer quelles règles appliquer :

```yaml
extends: ["spectral:oas"]
```

> **Analogie :** sans ce fichier, c'est comme lancer Analyse sans lui dire quel ennemi regarder.

**Aperçu dans VS Code** (extension OpenAPI) : la page interactive générée à partir du fichier. On y vérifie qu'il n'y a pas d'erreur, et que les astérisques rouges de `required` apparaissent bien dans la section **Schemas**.

> **Analogie :** la salle de simulation. On voit le résultat final en conditions réelles, sans rien risquer.

---

## 7. Résumé express

- **Contrat d'abord** (API-First) : le document OpenAPI est le briefing que toute l'équipe valide avant la mission.
- **URL = nom de ressource**, **verbe HTTP = action** : le Chocobo est la ressource, nourrir ou relâcher est l'action.
- **Stateless** : le garde n'a aucune mémoire, chaque requête présente tout.
- **Codes de statut** : `2xx` mission accomplie, `4xx` faute du client, `5xx` faute du serveur. `204` pour un succès sans corps.
- **`components` + `$ref`** : on forge la matéria une fois, on l'équipe partout (DRY).
- **JSON Schema** : `required`, `format`, `enum`, `pattern` et `additionalProperties: false` forment le contrôle d'accès du QG.
- **Spectral** : la capacité Analyse, qui vérifie la syntaxe et les bonnes pratiques sans rien exécuter.
