# Capstone : Blueprint StockMaster-Pro

Récapitulatif de ce qui a été vu et appris pendant le Capstone : concevoir un système complet (base de données, comportement, API, règles métier) où toutes les couches parlent exactement le même langage.

---

## 1. L'idée centrale : une source unique de vérité

| Notion                                          | Définition                                                                                                                                               |
| ----------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **SSOT** (_Single Source of Truth_)             | Une seule source de vérité : l'architecture est versionnée dans Git, au même endroit que le code, et relue par les pairs. On évite le « wiki obsolète ». |
| **Langage omniprésent** (_Ubiquitous Language_) | Un vocabulaire métier défini une fois, utilisé à l'identique dans le SQL, l'UML, l'API et le Gherkin.                                                    |
| **Cohérence inter-modèles**                     | Un même concept porte le même nom partout (`mouvement`, `emplacement`, `quantite`).                                                                      |
| **Test du grep**                                | L'auditeur cherche un mot-clé dans tout le dossier. S'il manque ou change d'orthographe quelque part, il y a une « friction sémantique ».                |

> **Analogie FFVII :** la Materia s'appelle « Materia » pour Cloud, pour la Shinra et pour le joueur. Si un document disait « Materia » et un autre « Orbe », personne ne saurait plus de quoi on parle.

---

## 2. Base de données (`01_database_schema.sql`)

### Les contraintes

| Contrainte                            | Rôle                                                                                                     |
| ------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| `PRIMARY KEY`                         | Identifie chaque ligne de façon unique.                                                                  |
| `GENERATED ALWAYS AS IDENTITY`        | PostgreSQL numérote lui-même chaque ligne (1, 2, 3...). Le compteur ne revient jamais en arrière.        |
| `UNIQUE (allee, rayon)`               | Contrainte sur un **couple** : ni l'allée seule, ni le rayon seul ne suffit à identifier un emplacement. |
| `FOREIGN KEY ... REFERENCES`          | Une valeur doit exister dans une autre table.                                                            |
| `CHECK (quantite > 0)`                | Refuse toute ligne qui ne respecte pas la condition.                                                     |
| `CHECK (... IN ('ENTREE', 'SORTIE'))` | N'accepte que les valeurs d'une liste.                                                                   |

### Les règles de conception

- **Cardinalité 1,1 / 0,n** : la clé étrangère va dans la table du côté **1,1**. Un emplacement contient un seul produit, donc `id_produit` est dans `emplacement`.
- **Association n,n** : elle donne une table de liaison. Une association **porteuse** a ses propres attributs (exemple : une quantité).
- **Non-redondance** : une information n'est stockée qu'à un seul endroit. Le mouvement désigne un emplacement, et le produit se retrouve via cet emplacement.
- **3NF** : on ne stocke pas une donnée calculable (dépendance transitive). C'est le cas de `montant_total` ou de `quantite_totale`.
- **2NF** : tout attribut non clé dépend de la **totalité** de la clé primaire. La 1NF, elle, impose des valeurs atomiques.
- **Un identifiant n'est pas une quantité** : un code-barres, un numéro de rayon ou un numéro de téléphone se stockent en texte (`VARCHAR`), jamais en `INT`.
- **Entier ou UUID** : l'entier est léger et lisible, l'UUID masque le volume de données et évite les collisions entre systèmes. Ici, une seule base : l'entier suffit.
- **`ON DELETE CASCADE`** : supprimer le parent supprime ses enfants. Le comportement par défaut est de refuser la suppression du parent. Dangereux pour un historique.

### Event Sourcing

On ne modifie jamais une quantité (`UPDATE`) : on **ajoute** un mouvement (`ENTREE` ou `SORTIE`) dans un historique immuable, et le stock se calcule avec un `SUM` des mouvements. On garde la trace de tout ce qui s'est passé.

### Une limite à connaître

Un `CHECK` ne voit que **la ligne qu'on insère**, pas les autres lignes de la table. Il ne peut donc pas calculer le stock. « Pas de stock négatif » est vérifié par l'**API**, et pas par le SQL.

---

## 3. Comportement (`02_behavioral_architecture.md`)

| Élément Mermaid         | Sens                                                               |
| ----------------------- | ------------------------------------------------------------------ |
| `actor` / `participant` | Une personne / un système.                                         |
| `->>`                   | Flèche pleine : une demande.                                       |
| `-->>`                  | Flèche en pointillés : une réponse.                                |
| `-x` et `-)`            | Messages asynchrones, sans attente de réponse (_fire and forget_). |
| `alt ... else ... end`  | Chemins **mutuellement exclusifs**, comme un `if / else`.          |
| `opt`                   | Un comportement optionnel, comme un `if` sans `else`.              |

### Notations UML à retenir

- **Composition** (losange **plein**) : les parties meurent avec le tout. **Agrégation** (losange **vide**) : les parties existent sans lui.
- **Héritage** : trait plein, pointe triangulaire vide. **Réalisation d'une interface** : pointillés, pointe triangulaire vide.
- **Composition plutôt qu'héritage** : l'héritage crée un couplage vertical rigide et fragile.
- **Pattern Repository** : une interface qui protège la logique métier des détails de la base.
- **Machine à états** : seules les transitions dessinées sont permises, ce qui interdit les changements d'état illégitimes.

---

## 4. Contrat d'API (`03_api_contract.yaml`)

| Mot-clé OpenAPI               | Rôle                                                   |
| ----------------------------- | ------------------------------------------------------ |
| `paths` / `post`              | Les routes et leurs méthodes HTTP.                     |
| `requestBody` / `schema`      | La forme exacte du JSON attendu.                       |
| `required`                    | Les champs obligatoires.                               |
| `enum` / `minimum`            | Valeurs autorisées / valeur minimale.                  |
| `$ref`                        | Renvoie vers un schéma défini une fois (principe DRY). |
| `additionalProperties: false` | Refuse tout champ non déclaré dans le contrat.         |
| `format: uuid`                | Valide qu'une chaîne est un UUID.                      |

### Alignement SQL ↔ YAML

- Le type doit correspondre : `INTEGER` en SQL donne `integer` en YAML. Un `uuid` en SQL donnerait `format: uuid`.
- Les conventions de nommage diffèrent (`id_emplacement` en SQL, `emplacementId` en YAML) : on les **mappe explicitement**.

### Codes HTTP

| Code              | Sens                                                             |
| ----------------- | ---------------------------------------------------------------- |
| `201 Created`     | Une nouvelle ressource a été créée.                              |
| `202 Accepted`    | Accepté, traitement pas encore terminé (file d'attente, worker). |
| `400 Bad Request` | La requête ne respecte pas le contrat.                           |
| `409 Conflict`    | La requête est valide, mais elle viole une règle métier.         |

> **Analogie FFVII :** dans une boutique, demander **-3 Potions** est un `400` (la demande est absurde). Demander **5 Potions** avec **12 gils** est un `409` : la demande est valide, mais la règle « pas assez de gils » l'interdit.

### REST orientée ressources

L'URL désigne un **nom au pluriel** (`/users/123`), et la méthode HTTP donne l'action (`GET`, `POST`, `PUT`, `DELETE`). Pas de verbe dans l'URL.

---

## 5. Spécifications métier (`04_business_specs.feature`)

| Mot-clé | Rôle                 | Pattern AAA |
| ------- | -------------------- | ----------- |
| `Given` | L'état de départ.    | Arrange     |
| `When`  | L'action.            | Act         |
| `Then`  | Le résultat attendu. | Assert      |

- **BDD** : le fichier est lisible par le métier et exécutable par les machines. Il décrit le **quoi**, pas le **comment** : jamais de `POST` ni de `INSERT`.
- **`Scenario Outline` + `Examples`** : un scénario écrit une fois avec des trous (`<quantite>`), rejoué pour chaque ligne du tableau.
- **Valeurs limites** : on teste de chaque côté de la frontière (stock 9 : sortie de 9 acceptée, sortie de 10 refusée), plus le cas de l'emplacement vide.
- **INVEST** : _Independent, Negotiable, Valuable, Estimable, Small, Testable_. **Testable** veut dire que les critères permettent un test binaire (succès ou échec).

---

## 6. L'audit : trois tests

| Test               | Ce qu'il vérifie                                          | Comment                                             |
| ------------------ | --------------------------------------------------------- | --------------------------------------------------- |
| **Grep**           | La racine sémantique est la même dans les 4 fichiers.     | `grep -ri "mouvement" .`                            |
| **Étanchéité SQL** | La base elle-même refuse un mouvement de `-500`.          | Insertion dans PostgreSQL : refusée par le `CHECK`. |
| **Compilation**    | Les fichiers sont valides, sans aucune erreur de syntaxe. | `spectral lint`, `psql -f`, aperçu Mermaid.         |

### Qui protège quoi

| Règle                               | SQL                    | API            |
| ----------------------------------- | ---------------------- | -------------- |
| Quantité strictement positive       | `CHECK (quantite > 0)` | `minimum: 1`   |
| Type de mouvement valide            | `CHECK ... IN (...)`   | `enum`         |
| Sortie inférieure ou égale au stock | non                    | `409 Conflict` |

> **À garder en tête :** un `UPDATE` sur un mouvement existant reste possible côté SQL : l'immutabilité est ici une règle de conception, pas une protection technique. Un trigger pourrait la renforcer.
