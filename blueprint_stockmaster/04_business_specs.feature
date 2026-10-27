Feature: Traçabilité et sécurisation des mouvements d'inventaire.
  Scenario: Un mouvement d'ENTREE qui augmente le stock disponible
    Given l'emplacement B4 contient 9 consoles PS5
    When un manutentionnaire scanne 3 consoles PS5 en entrée
    Then il y a désormais 12 consoles PS5 dans l'emplacement B4

  Scenario Outline: Pour les sorties de stock
    Given l'emplacement <emplacement> contient <disponible> <produit>
    When un manutentionnaire scanne <quantite> <produit> en sortie
    Then le résultat est <resultat>

    Examples:
      | emplacement | disponible | produit      | quantite | resultat |
      | B4          | 9          | consoles PS5 | 3        | acceptée |
      | B4          | 9          | consoles PS5 | 10       | refusée  |
      | B4          | 9          | consoles PS5 | 9        | acceptée |
      | B4          | 0          | consoles PS5 | 1        | refusée  |
