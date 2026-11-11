-- m5_consultas_joins.sql
-- cruces con JOIN sobre Ventas_Tech_DB, carpeta RetailPro
-- Julian

USE Ventas_Tech_DB;
GO

-- en M3 cargué 5 clientes y 6 productos pero todos tenían ventas, entonces para poder
-- mostrar algo en las consultas 2 y 3 (los LEFT JOIN) agrego acá 2 clientes y 2 productos
-- nuevos que todavía no vendieron nada. la ciudad ya la tenía clientes desde M3 asi que
-- no hizo falta agregar ninguna tabla nueva para la parte geográfica
INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro) VALUES
  (6, 'Jorge Medina',  'jorge@mail.com', 'Buenos Aires', '2024-03-20'),
  (7, 'Sofía Benítez', 'sofia@mail.com', 'Córdoba',      '2024-03-22');

INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo) VALUES
  (7, 'Webcam HD',       2,  45.00, 25, 1),
  (8, 'Impresora Láser', 1, 320.00,  6, 1);
GO

-- consulta 1: vista completa para power bi, cruzando venta + cliente + producto + categoria
SELECT
    v.fecha_venta,
    v.id_cliente,
    cli.nombre AS nombre_cliente,
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
-- hallazgo: las ventas que tengo cargadas caen en 3 categorías nada más (computación,
-- accesorios y almacenamiento), todavía no se vendió nada de audio

-- consulta 2: clientes que nunca compraron, para que los vea CRM
SELECT cli.nombre, cli.email, cli.fecha_registro
FROM clientes cli
LEFT JOIN ventas v ON cli.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;
GO
-- hallazgo: 2 de los 7 clientes (Jorge y Sofía) nunca compraron, los dos se registraron
-- el mismo mes, se les podría mandar algo para que hagan la primera compra

-- consulta 3: productos que nunca se vendieron
SELECT p.nombre_producto, cat.nombre_categoria, p.precio
FROM productos p
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;
GO
-- hallazgo: webcam e impresora todavía no vendieron nada, son productos nuevos asi que
-- tampoco es para alarmarse pero hay que seguirlos el mes que viene

-- consulta 4: comparo facturación por canal.
-- no tengo una columna "canal" en ninguna tabla, la invento yo acá: tomo a Buenos Aires
-- como canal online (es donde está centralizada la operación) y el resto de las
-- provincias como canal presencial, por los distribuidores regionales
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
-- hallazgo: presencial factura más que online (3804 contra 2640), aunque online depende
-- de un solo cliente de Buenos Aires asi que si deja de comprar ese canal se cae a cero
