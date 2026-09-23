-- ══════════════════════════════════════════
-- BodegaTech — Script de Inventario
-- Autor: Julian Barnasthpol
-- Fecha: 2026-09-23
-- ══════════════════════════════════════════

-- ── SECCIÓN DDL ──────────────────────────

-- DROP TABLE
DROP TABLE IF EXISTS inventario;

-- CREATE TABLE
CREATE TABLE inventario (
	id_producto      INT NOT NULL PRIMARY KEY,     -- número entero: identifica a cada producto
	nombre_producto  VARCHAR(100) NOT NULL,        -- texto de hasta 100 caracteres, NOT NULL porque todo producto necesita ser identificado
	categoria        VARCHAR(50) NOT NULL,         -- texto de hasta 50 caracteres, tal como pide la consigna
	precio_unitario  DECIMAL(10,2),                -- DECIMAL y no FLOAT: para dinero necesitamos precisión exacta, sin errores de redondeo
	stock_actual     INT NOT NULL,                 -- número entero: para identificar la cantidad actual de dicho producto
	stock_minimo     INT NOT NULL,                 -- número entero: para identificar el stock mínimo necesario del producto
	fecha_ingreso    DATE NOT NULL,                -- solo fecha (sin hora), alcanza para saber cuándo se registró el producto
	activo           BIT                           -- BIT (0/1) en vez de texto: más óptimo para identificar si está o no activo
);

-- ── SECCIÓN DML ──────────────────────────

-- INSERT INTO
INSERT INTO inventario (id_producto, nombre_producto, categoria, precio_unitario, stock_actual, stock_minimo, fecha_ingreso, activo)
VALUES
  (1, 'Laptop Pro 15', 'Computación', 1200.00, 15, 3, '2024-01-10', 1),
  (2, 'Mouse Inalámbrico', 'Accesorios', 28.00, 80, 10, '2024-01-10', 1),
  (3, 'Monitor 4K 27"', 'Computación', 450.00, 12, 2, '2024-01-15', 1),
  (4, 'Teclado Mecánico', 'Accesorios', 95.00, 40, 5, '2024-01-15', 1),
  (5, 'Laptop Basic 14', 'Computación', 650.00, 20, 3, '2024-02-01', 1),
  (6, 'Auriculares BT Pro', 'Audio', 120.00, 35, 5, '2024-02-01', 1),
  (7, 'Hub USB-C 7 puertos', 'Accesorios', 45.00, 60, 10, '2024-02-10', 1),
  (8, 'Webcam HD 1080p', 'Accesorios', 85.00, 25, 5, '2024-02-10', 1),
  (9, 'SSD Externo 1TB', 'Almacenamiento', 130.00, 18, 3, '2024-03-01', 1),
  (10, 'Parlante Bluetooth', 'Audio', 60.00, 45, 8, '2024-03-01', 1);

-- UPDATE ventas del día
UPDATE inventario SET stock_actual = stock_actual - 3
WHERE id_producto = 1;

UPDATE inventario SET stock_actual = stock_actual - 12
WHERE id_producto = 2;

UPDATE inventario SET stock_actual = stock_actual - 5
WHERE id_producto = 6;

-- UPDATE producto descontinuado
UPDATE inventario SET activo = 0
WHERE id_producto = 8;

-- SELECT validaciones
SELECT * FROM inventario;
