-- m4_consultas_negocio.sql
-- consultas de agregación sobre Ventas_Tech_DB (la base del M3)
-- Julian

USE Ventas_Tech_DB;
GO

-- 1) resumen del mes: cuánto facturamos, cuántos pedidos y el ticket promedio
-- con los datos que cargué todo es de marzo 2024 asi que da una sola fila, es lo esperado
SELECT
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta);
GO

-- 2) top 5 productos que más facturaron
SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;
GO

-- 3) clientes que compraron más de una vez
SELECT
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;
GO

-- 4) qué productos quedan arriba o abajo del promedio de facturación
-- ojo: es el promedio de los totales por producto, no el promedio de cada venta suelta
WITH totales_por_producto AS (
    SELECT id_producto, SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY id_producto
)
SELECT
    id_producto,
    total_facturado,
    CASE WHEN total_facturado > (SELECT AVG(total_facturado) FROM totales_por_producto)
         THEN 'Por encima' ELSE 'Por debajo' END AS posicion_vs_promedio
FROM totales_por_producto
ORDER BY total_facturado DESC;
GO

-- hallazgos:
-- el producto 1 (la laptop) se lleva más de la mitad de todo lo facturado, 3600 de 6444
-- los 5 clientes compraron justo 2 veces cada uno, no hay ninguno que se destaque de los demás
-- solo 2 productos de 6 superan el promedio de facturación ($1074), el resto queda bastante por debajo
