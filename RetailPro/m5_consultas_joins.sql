-- ============================================================
-- RetailPro — m5_consultas_joins.sql
-- Pre-entrega 5: Consultas con JOINs para el proyecto
-- Autor: Julian Barnasthpol
-- Fecha: 2026-11-11
-- Base de datos: Ventas_Tech_DB (creada en M3)
-- ============================================================

USE Ventas_Tech_DB;
GO

-- ------------------------------------------------------------
-- Datos extra para esta pre-entrega
-- En M3 cargamos 5 clientes y 6 productos, pero todos tienen al
-- menos una venta asociada. Para poder mostrar algo con el LEFT
-- JOIN de las consultas 2 y 3 (clientes/productos sin ventas)
-- agrego acá 2 clientes y 2 productos nuevos que todavía no
-- compraron/no se vendieron. La dimensión geográfica (ciudad) ya
-- la tenía la tabla clientes desde M3, así que no hizo falta
-- agregar una tabla nueva para eso.
-- ------------------------------------------------------------
INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro) VALUES
  (6, 'Jorge Medina',   'jorge@mail.com',  'Buenos Aires', '2024-03-20'),
  (7, 'Sofía Benítez',  'sofia@mail.com',  'Córdoba',      '2024-03-22');

INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo) VALUES
  (7, 'Webcam HD',        2,  45.00, 25, 1),
  (8, 'Impresora Láser',  1, 320.00,  6, 1);
GO

-- ------------------------------------------------------------
-- Consulta 1: Vista base del proyecto (INNER JOIN)
-- Propósito: cruzar ventas con clientes, productos y categorías
-- para tener en una sola fila todo lo que necesita Power BI en M7.
-- La ciudad sirve para agrupar/filtrar por zona, la categoría para
-- agrupar por tipo de producto.
-- ------------------------------------------------------------
SELECT
    v.fecha_venta,
    v.id_cliente,
    cli.nombre            AS nombre_cliente,
    cli.ciudad,
    p.nombre_producto,
    cat.nombre_categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario AS total_venta
FROM ventas v
INNER JOIN clientes   cli ON v.id_cliente   = cli.id_cliente
INNER JOIN productos  p   ON v.id_producto  = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria;
GO
-- Hallazgo: las 10 ventas quedan repartidas en 3 categorías (Computación,
-- Accesorios y Almacenamiento, no hay ventas de Audio todavía), y Buenos
-- Aires concentra el ticket más alto por ser donde está el cliente que
-- compró la Laptop Pro dos veces.

-- ------------------------------------------------------------
-- Consulta 2: Clientes sin ventas (LEFT JOIN)
-- Propósito: detectar clientes registrados que nunca compraron,
-- para que el área de CRM los contacte.
-- ------------------------------------------------------------
SELECT
    cli.nombre,
    cli.email,
    cli.fecha_registro
FROM clientes cli
LEFT JOIN ventas v ON cli.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;
GO
-- Hallazgo: 2 de los 7 clientes registrados (Jorge Medina y Sofía Benítez)
-- nunca compraron. Los dos se registraron el mismo mes que las ventas que
-- sí tenemos, así que CRM podría contactarlos con una oferta de bienvenida.

-- ------------------------------------------------------------
-- Consulta 3: Productos sin ventas (LEFT JOIN)
-- Propósito: detectar productos del catálogo sin movimiento,
-- para que el área de producto evalúe si conviene promocionarlos
-- o directamente sacarlos del catálogo.
-- ------------------------------------------------------------
SELECT
    p.nombre_producto,
    cat.nombre_categoria,
    p.precio
FROM productos p
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;
GO
-- Hallazgo: 2 de los 8 productos (Webcam HD e Impresora Láser) no
-- registran ninguna venta. Ambos son productos cargados recientemente,
-- así que todavía puede ser pronto para sacar conclusiones, pero conviene
-- vigilarlos el próximo mes.

-- ------------------------------------------------------------
-- Consulta 4: Consolidado por canal (UNION ALL)
-- Propósito: comparar facturación entre dos canales de venta.
-- RetailPro no tiene una columna "canal" en la base, así que la
-- armamos nosotros: tratamos a Buenos Aires como el canal "Online"
-- (donde está centralizada la operación) y al resto de las
-- provincias como "Presencial" (venta a través de distribuidores
-- regionales). El valor de canal es literal, no viene de ninguna
-- tabla.
-- ------------------------------------------------------------
SELECT canal, SUM(total) AS total_canal
FROM (
    SELECT v.fecha_venta, v.cantidad * v.precio_unitario AS total, 'Online' AS canal
    FROM ventas v
    INNER JOIN clientes c ON v.id_cliente = c.id_cliente
    WHERE c.ciudad = 'Buenos Aires'

    UNION ALL

    SELECT v.fecha_venta, v.cantidad * v.precio_unitario AS total, 'Presencial' AS canal
    FROM ventas v
    INNER JOIN clientes c ON v.id_cliente = c.id_cliente
    WHERE c.ciudad <> 'Buenos Aires'
) AS consolidado
GROUP BY canal;
GO
-- Hallazgo: el canal Presencial factura $3804 contra $2640 del Online,
-- un 59% contra 41%, aunque Online depende de un solo cliente de Buenos
-- Aires. Si ese cliente deja de comprar, el canal Online se cae a cero.
