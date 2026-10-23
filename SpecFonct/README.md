# Spécifications Fonctionnelles, User Stories & Gherkin (BDD)

Récapitulatif de ce qui a été vu et appris dans le projet `Analyse_et_conception/SpecFonct`.

---

## 1. Pourquoi spécifier le besoin avant de coder ?

Un logiciel techniquement parfait est inutile s'il ne résout pas le bon problème métier. L'**ingénierie des exigences** (_Requirement Engineering_) est la discipline qui consiste à **capturer, affiner et documenter le besoin réel**.

Le risque principal pour un développeur : passer deux semaines à coder une fonctionnalité, puis s'entendre dire en démonstration « ce n'est pas du tout ce que j'avais demandé ». Une spécification claire et sans ambiguïté est le meilleur bouclier.

### Source Unique de Vérité (SSOT)

Le fichier `.feature` en Gherkin devient la **Source Unique de Vérité** (_Single Source Of Truth_) : un seul document, compris à la fois par le métier (Product Owner) et par l'ingénierie (développeurs, QA).

---

## 2. Séparer le métier du technique

Un brief client mélange souvent le **besoin métier** et des **solutions techniques** imaginées par le client (SQL, API, interface graphique). Le rôle de l'ingénieur est de « nettoyer » la demande.

| Dans le brief du client                | Partie métier (à garder)                           | Partie technique (à jeter) |
| -------------------------------------- | -------------------------------------------------- | -------------------------- |
| requête SQL sur `blacklist_pays`       | le pays est vérifié selon le registre des embargos | SQL, nom de table          |
| l'API renvoie une erreur 403           | le paiement est refusé                             | API, code HTTP             |
| popup rouge `div class="alert-danger"` | le client est notifié du refus                     | popup, HTML, CSS           |

> **Les règles métier survivent aux technologies.** Si le système passe demain à une architecture asynchrone (Kafka, sans HTTP) ou à une application mobile native, une spécification qui parlerait d'« erreur 403 » deviendrait fausse, alors que la règle financière n'a pas changé.

> **Analogie FFVII :** l'objectif d'Avalanche, c'est d'empêcher la Shinra de vider la Planète de sa Mako. C'est le **besoin métier**. « Poser une bombe sur le réacteur » n'est qu'une **solution technique** parmi d'autres. Et l'objectif « sauver la Planète » reste le même, qu'on voyage en Buggy, à dos de Chocobo ou en Highwind : les véhicules sont les technologies, la quête est la règle métier.

### Le langage omniprésent (_Ubiquitous Language_)

Notion issue du **Domain-Driven Design** : les termes utilisés dans le fichier Gherkin doivent se retrouver **à la lettre près** dans les noms de classes, de méthodes et de tables SQL. C'est l'alignement entre le métier et l'infrastructure.

> **Analogie FFVII :** dans tout le jeu, tout le monde dit « Mako », « Matéria » et « Shinra », des dialogues aux boutiques. Si l'équipe métier disait « Mako » et que le code parlait d'« énergie_vitale », on se comprendrait mal : un même mot doit désigner la même chose partout.

---

## 3. Le PRD et la User Story

### Le PRD (_Product Requirement Document_)

Document qui décrit ce qu'un produit ou une fonctionnalité doit faire et pourquoi.

### La User Story (US)

Format canonique :

```
En tant que [rôle],
je veux [action],
afin de [valeur].
```

- **Rôle** : qui exprime le besoin.
- **Action** : ce que le système doit faire, côté métier, sans dire comment.
- **Valeur** : pourquoi c'est utile (ce qui justifie la fonctionnalité).

### Les critères d'acceptation

Ce sont des conditions **vérifiables** (réponse « oui » ou « non »), écrites en langage naturel. Ils décrivent ce qui doit être vrai, pas la manière dont le système y parvient.

### Les critères INVEST

Une bonne User Story respecte :

| Lettre | Critère     | Signification                                      |
| ------ | ----------- | -------------------------------------------------- |
| **I**  | Independent | peut être développée sans dépendre d'une autre     |
| **N**  | Negotiable  | le détail se discute, ce n'est pas un contrat figé |
| **V**  | Valuable    | apporte une valeur au métier                       |
| **E**  | Estimable   | on peut estimer l'effort nécessaire                |
| **S**  | Small       | assez petite pour tenir dans une itération         |
| **T**  | Testable    | on peut vérifier qu'elle est satisfaite            |

---

## 4. Le BDD et la syntaxe Gherkin

**BDD (_Behavior-Driven Development_)** : on écrit d'abord le **comportement attendu** du système, dans un langage que tout le monde comprend, avant d'écrire le code. Ce n'est pas un outil de test, c'est un **outil de conception**.

**Gherkin** : le langage structuré utilisé pour écrire ces spécifications, dans des fichiers `.feature`. Les mots-clés restent en anglais ; seul le texte qui les suit est en français.

### Les mots-clés

| Mot-clé      | Rôle                                                                |
| ------------ | ------------------------------------------------------------------- |
| `Feature`    | titre de la fonctionnalité et son contexte (rôle, besoin, valeur)   |
| `Background` | étapes communes à tous les scénarios, jouées avant chacun           |
| `Scenario`   | un comportement précis, décrit par un exemple                       |
| `Given`      | le **contexte de départ** : l'état du monde avant l'événement       |
| `When`       | l'**événement déclencheur** : une seule action métier atomique      |
| `Then`       | le **résultat attendu** : ce que le système doit faire              |
| `And`        | prolonge l'étape précédente, sans répéter `Given`, `When` ou `Then` |

### Lien avec Arrange-Act-Assert

| Gherkin | Pattern de test        |
| ------- | ---------------------- |
| `Given` | **Arrange** (préparer) |
| `When`  | **Act** (agir)         |
| `Then`  | **Assert** (vérifier)  |

> **Analogie FFVII :** un tour de combat.
>
> - `Given` : Cloud est en combat contre un Soldat Shinra, avec la Matéria Feu équipée et assez de PM.
> - `When` : Cloud lance Feu sur le Soldat.
> - `Then` : le Soldat perd des PV et les PM de Cloud diminuent.

### Le piège du `When`

Le `When` doit représenter **une seule action métier**. Ne pas y empiler « le client ajoute au panier ET navigue vers la caisse ET entre sa carte ET clique sur payer » : tout ce qui précède l'action déclenchante relève du `Given`.

> **Analogie FFVII :** dans le menu de combat, on choisit **une seule commande** à la fois (Attaquer, Magie, Objet). On ne peut pas sélectionner « attaquer + se soigner + invoquer » en une seule action : une action déclenchante, une réaction du système.

### Exemple

```gherkin
Scenario: Validation d'un paiement standard sans risque
  Given Un client standard
  And Une commande d'un montant de 5000 euros à destination de la "France"
  When Le client soumet son paiement
  Then Le paiement est accepté par la gouvernance
```

---

## 5. Gérer la complexité : `Scenario Outline` et `Examples`

Quand le même scénario doit être joué avec beaucoup de combinaisons de valeurs, on évite de le dupliquer. On écrit **un modèle** avec des **paramètres entre chevrons** `<...>`, et un tableau `Examples:` fournit les valeurs. Le scénario est rejoué **une fois par ligne** du tableau.

```gherkin
Scenario Outline: Blocage par la gouvernance selon la matrice de risque
  Given Un client standard avec une commande de <montant_commande> euros vers la <pays_destination>
  When Le client soumet son paiement
  Then Le paiement est <decision_paiement> par la gouvernance

  Examples:
    | montant_commande | pays_destination | decision_paiement |
    | 10000            | "Syldavie"       | accepté           |
    | 10001            | "Syldavie"       | refusé            |
```

> **Analogie FFVII :** c'est le même tour de combat (« Cloud lance une Matéria sur un ennemi ») écrit **une seule fois**, avec deux trous : `<materia>` et `<ennemi>`. Le tableau `Examples:` liste ensuite les combinaisons à essayer, au lieu de réécrire le combat pour chaque cas.

### Règles à retenir

- Les **en-têtes du tableau** doivent correspondre **au caractère près** aux noms des paramètres `<...>` (sans les chevrons).
- Les barres verticales `|` doivent être alignées.
- Un paramètre mal orthographié est une variable « orpheline » : l'IDE la souligne en rouge.
- Le résultat peut lui aussi être un paramètre (accepté ou refusé selon la ligne).

---

## 6. L'analyse des valeurs limites (_Boundary Value Analysis_)

Les bugs en production viennent très souvent des **frontières**. Si la règle dit « le montant **dépasse** 10 000 euros », il faut tester la borne pour savoir si elle est incluse ou exclue.

| Montant   | Résultat (pays sous embargo) | Ce que ça prouve                                                 |
| --------- | ---------------------------- | ---------------------------------------------------------------- |
| 9999      | accepté                      | juste sous la borne                                              |
| **10000** | **accepté**                  | la borne est **exclue** (le seuil est « strictement supérieur ») |
| 10001     | refusé                       | juste au-dessus de la borne                                      |

Une couverture complète croise aussi les différentes **branches** de la règle : cas nominal, cas aux limites, chemins d'erreur, et exception (statut VIP).

> **Analogie FFVII :** un ennemi est mis KO quand ses PV tombent à 0. Pour savoir si la frontière est incluse, on ne teste pas un ennemi à 50 PV : on teste à **1 PV**, à **0 PV** et à **-1**. La question « à 0 PV, est-il KO ? » est exactement la question « à 10 000, est-ce bloqué ? ».

---

## 7. Valider une spécification

### Validation syntaxique (linter)

- Les mots-clés sont **colorés** par l'extension _Cucumber (Gherkin) Full Support_.
- Le tableau `Examples:` est **aligné**.
- Aucune variable de `<...>` n'est **orpheline** (pas de soulignement rouge).

### Validation sémantique : le « test de la grand-mère »

On lit le scénario à voix haute à quelqu'un qui n'y connaît rien en informatique.

- S'il demande « qu'est-ce qu'une table de base de données ? » ou « c'est quoi une erreur 403 ? » : la spécification est **trop couplée à la technique**, elle a échoué.
- S'il conclut « donc on bloque les grosses sommes qui partent vers des pays dangereux, sauf pour les clients premium » : la modélisation est réussie.

> **Analogie FFVII :** si un simple habitant de Kalm, qui n'a jamais entendu parler de Matéria ni de réacteur, comprend la règle du premier coup, la spécification est bonne. S'il faut lui expliquer le jargon technique, elle est trop couplée à la technique.

### Les « Trois Amigos »

Cérémonie de revue entre pairs où trois rôles relisent le fichier ensemble :

- un **développeur** (l'ingénierie),
- un **testeur QA** (la qualité),
- un **Product Owner** (le métier).

> **Analogie FFVII :** avant une mission, Barret (qui fixe l'objectif de la mission, comme le Product Owner), Cloud (qui l'exécute, comme le développeur) et Tifa (qui vérifie que le plan tient la route, comme la QA) relisent le plan ensemble. Chacun apporte un regard différent.

---

## 8. À retenir

- La spécification décrit le **quoi** (comportement métier), jamais le **comment** (technologie).
- Une US suit « En tant que… je veux… afin de… » et respecte INVEST.
- `Given` = contexte, `When` = action unique, `Then` = résultat.
- `Scenario Outline` + `Examples` évitent de dupliquer un scénario.
- On teste toujours les **valeurs limites**.
- Le fichier `.feature` est la **Source Unique de Vérité** partagée entre le métier et l'ingénierie.
