-- Script d'initialisation de la base MegaShop-B2B
-- Auteur : Kévin FRESNE

BEGIN;

-- Suppression des tables, dans l'ordre inverse des dépendances
DROP TABLE IF EXISTS ligne_commande CASCADE;

DROP TABLE IF EXISTS commande CASCADE;

DROP TABLE IF EXISTS produit CASCADE;

DROP TABLE IF EXISTS client CASCADE;

-- Table CLIENT
CREATE TABLE client (
    id_client UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    client_nom VARCHAR(100) NOT NULL,
    client_contact VARCHAR(255) NOT NULL
);

-- Table PRODUIT
CREATE TABLE produit (
    code_prod VARCHAR(20) PRIMARY KEY,
    designation VARCHAR(150) NOT NULL,
    prix_unitaire_ht DECIMAL(10, 2) NOT NULL
);

-- Table COMMANDE
CREATE TABLE commande (
    id_cmd VARCHAR(20) PRIMARY KEY,
    date_achat DATE NOT NULL,
    statut_cmd VARCHAR(20) NOT NULL,
    CHECK (
        statut_cmd IN ('EN_COURS', 'LIVREE')
    ),
    adr_livraison VARCHAR(255) NOT NULL,
    id_client UUID NOT NULL,
    CONSTRAINT fk_commande_client FOREIGN KEY (id_client) REFERENCES client (id_client) ON DELETE RESTRICT
);

-- Table LIGNE_COMMANDE : traduction de l'association porteuse "Contient"
-- Chaque ligne signifie : "dans cette commande, ce produit, en telle quantité"
CREATE TABLE ligne_commande (
    -- Quelle commande
    id_cmd    VARCHAR(20) NOT NULL,
    -- Quel produit
    code_prod VARCHAR(20) NOT NULL,
    -- Combien d'exemplaires
    qte       INTEGER     NOT NULL,

-- Une seule ligne par couple (commande, produit)
PRIMARY KEY (id_cmd, code_prod),

-- La quantité doit être supérieure à 0
CHECK (qte > 0),

-- Commande supprimée : ses lignes sont supprimées aussi
CONSTRAINT fk_ligne_commande FOREIGN KEY (id_cmd) REFERENCES commande (id_cmd) ON DELETE CASCADE,

-- Produit déjà commandé : suppression refusée
CONSTRAINT fk_ligne_produit
        FOREIGN KEY (code_prod) REFERENCES produit (code_prod)
        ON DELETE RESTRICT
);

COMMIT;
