# Architecture comportementale : StockMaster-Pro

## Déclaration d'un mouvement de stock

```mermaid
sequenceDiagram
    actor Manutentionnaire
    participant API as API StockMaster-Pro
    participant Base as Base PostgreSQL

    Manutentionnaire->>API: POST /inventory/movements (emplacementId, typeMouvement, quantite)
    API->>Base: SELECT stock actuel de l'emplacement
    Base-->>API: stock actuel

    alt stock actuel suffisant
        API->>Base: INSERT mouvement_stock (id_emplacement, type_mouvement, quantite)
        Base-->>API: mouvement créé
        API-->>Manutentionnaire: 201 Created
    else stock actuel insuffisant
        API-->>Manutentionnaire: 409 Conflict (Quantité disponible insuffisante)
    end
```

## Correspondance YAML ↔ SQL

| API (`03_api_contract.yaml`) | Base (`01_database_schema.sql`)  |
| ---------------------------- | -------------------------------- |
| `emplacementId`              | `mouvement_stock.id_emplacement` |
| `typeMouvement`              | `mouvement_stock.type_mouvement` |
| `quantite`                   | `mouvement_stock.quantite`       |
