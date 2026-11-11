-- ============================================================
-- RetailPro — m4_consultas_negocio.sql
-- Pre-entrega 4: Consultas SQL de negocio
-- Autor: Julian Barnasthpol
-- Fecha: 2026-11-11
-- Base de datos: Ventas_Tech_DB (creada en M3)
-- ============================================================

USE Ventas_Tech_DB;
GO

-- === Consulta 1: Resumen ejecutivo mensual ===
-- Total facturado, cantidad de pedidos y ticket promedio, agrupados por mes.
-- Con los datos cargados en M3 todas las ventas son de marzo 2024, por eso
-- da una sola fila.
SELECT
    MONTH(fecha_venta)                 AS mes,
    SUM(cantidad * precio_unitario)    AS total_facturado,
    COUNT(*)                           AS cantidad_pedidos,
    AVG(cantidad * precio_unitario)    AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta);
GO

-- === Consulta 2: Ranking de productos ===
-- Top 5 productos por total facturado, con las unidades vendidas de cada uno.
SELECT TOP 5
    id_producto,
    SUM(cantidad)                      AS unidades_vendidas,
    SUM(cantidad * precio_unitario)    AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;
GO

-- === Consulta 3: Clientes recurrentes ===
-- Clientes con más de un pedido, con la cantidad de pedidos y el total gastado.
SELECT
    id_cliente,
    COUNT(*)                           AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)    AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;
GO

-- === Consulta 4: Productos por encima/por debajo del promedio ===
-- Importante: es el promedio de los TOTALES por producto, no el promedio
-- de cada fila de ventas. Por eso primero armamos los totales en el WITH
-- y después comparamos cada uno contra el promedio de esa tabla intermedia.
WITH totales_por_producto AS (
    SELECT
        id_producto,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY id_producto
)
SELECT
    id_producto,
    total_facturado,
    CASE
        WHEN total_facturado > (SELECT AVG(total_facturado) FROM totales_por_producto)
            THEN 'Por encima'
        ELSE 'Por debajo'
    END AS posicion_vs_promedio
FROM totales_por_producto
ORDER BY total_facturado DESC;
GO

-- === Hallazgos ===
-- 1. El producto 1 (Laptop Pro 15) concentra $3600 de los $6444 facturados
--    en el trimestre, casi el 56% del total. Es por lejos el que más pesa.
-- 2. Los 5 clientes hicieron exactamente 2 pedidos cada uno, ninguno se
--    repite más que el resto. La base de clientes está pareja, no hay un
--    comprador que destaque por volumen.
-- 3. Solo 2 de los 6 productos (el 1 y el 3) quedan por encima del promedio
--    de facturación por producto (~$1074). Los otros 4 están todos por
--    debajo, algo lógico cuando un solo producto se lleva más de la mitad.
