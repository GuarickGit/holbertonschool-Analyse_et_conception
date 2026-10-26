CREATE TABLE produit (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code_barre VARCHAR(20) UNIQUE NOT NULL,
    nom VARCHAR(50) NOT NULL
);

CREATE TABLE emplacement (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    allee VARCHAR(20) NOT NULL,
    rayon VARCHAR(20) NOT NULL,
    id_produit INTEGER NOT NULL,
    UNIQUE (allee, rayon),
    FOREIGN KEY (id_produit) REFERENCES produit (id)
);

CREATE TABLE mouvement_stock (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_emplacement INTEGER NOT NULL,
    type_mouvement VARCHAR(10) NOT NULL CHECK (
        type_mouvement IN ('ENTREE', 'SORTIE')
    ),
    quantite INTEGER NOT NULL CHECK (quantite > 0),
    date_mouvement TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_emplacement) REFERENCES emplacement (id)
);
