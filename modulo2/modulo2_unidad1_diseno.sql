-- ============================================================
-- Módulo 2 · Unidad 1 · Diseño de tablas: sistema de ventas
-- Motor: SQL Server (IDENTITY para autoincremental)
-- ============================================================

CREATE TABLE clientes (
    id_cliente     INT IDENTITY(1,1) PRIMARY KEY,   -- número entero: identifica a cada cliente de forma única y automática
    nombre         VARCHAR(100) NOT NULL,           -- texto de hasta 100 caracteres, tal como pide la consigna; NOT NULL porque todo cliente necesita un nombre
    perfil_bio     VARCHAR(MAX),                    -- texto largo para notas o biografía; VARCHAR(MAX) porque una bio puede ser extensa y no sabemos su límite de antemano; sin NOT NULL porque es un dato opcional
    fecha_registro DATE                             -- solo fecha (sin hora), alcanza para saber cuándo se registró el cliente
);

CREATE TABLE productos (
    id_producto  INT IDENTITY(1,1) PRIMARY KEY,     -- número entero: identifica a cada producto de forma única y automática
    descripcion  VARCHAR(255) NOT NULL,             -- texto de hasta 255 caracteres, tal como pide la consigna
    precio       DECIMAL(10,2),                     -- DECIMAL y no FLOAT: para dinero necesitamos precisión exacta, sin errores de redondeo;
                                                     -- 10 dígitos en total, 2 después de la coma (hasta 99.999.999,99)
    esta_activo  BIT                                -- BIT (0/1) en vez de texto: es más eficiente que VARCHAR y representa
                                                     -- justo lo que necesitamos, un valor de sí/no (¿está a la venta o no?)
);
