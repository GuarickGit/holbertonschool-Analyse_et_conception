# Règles de gestion — MegaShop-B2B

## Sujets identifiés

- **Client** : `client_nom`, `client_contact`
- **Commande** : `id_cmd`, `date_achat`, `statut_cmd`, `adr_livraison`
- **Produit** : `code_prod`, `designation`, `prix_unitaire_ht`
- **Association Commande ↔ Produit** : porte `qte`

## Donnée calculée (non stockée)

- `total_ligne` = `prix_unitaire_ht` × `qte`

## Règles de gestion

**RG1 — Client ↔ Commande**

- Un client peut passer plusieurs commandes, ou aucune.
- Une commande est passée par un seul client.
- Cardinalités : Client (0,N) — Commande (1,1)

**RG2 — Commande ↔ Produit** (association porteuse de `qte`)

- Une commande contient au moins un produit, et peut en contenir plusieurs.
- Un produit peut figurer dans plusieurs commandes, ou dans aucune.
- Cardinalités : Commande (1,N) — Produit (0,N)

**RG3 — Adresse de livraison**

- Une commande est livrée à une seule adresse, choisie pour cette commande.
- L'adresse est un attribut de la commande, pas du client.
