CREATE TABLE products (
    product_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    barcode VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE locations (
    location_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    aisle VARCHAR(20) NOT NULL,
    rack VARCHAR(20) NOT NULL,
    UNIQUE (aisle, rack),
    product_id INTEGER NOT NULL REFERENCES products (product_id)
);

CREATE TABLE movements (
    movement_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    location_id INTEGER NOT NULL REFERENCES locations (location_id),
    quantity INTEGER NOT NULL CHECK (quantity <> 0),
    moved_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
