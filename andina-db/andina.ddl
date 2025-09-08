-- =====================================================
-- ANDINA DB - Sistema de Ventas de Librería
-- =====================================================
-- Descripción: Base de datos para gestión de ventas de libros
--              especializados en tecnología y literatura andina
-- Autor: Sistema Andina
-- Versión: 1.0
-- Compatibilidad: PostgreSQL 12+
-- =====================================================

-- =====================================================
-- CONFIGURACIÓN DE LOGGING Y SPOOL
-- =====================================================

-- Debe existir el directorio de logs antes de ejecutar este script.

-- Configurar spool para capturar toda la salida
\o | cat > "logs/andina_db_install_$(date +%Y%m%d_%H%M%S).log"

-- Mostrar información de inicio
\echo '====================================================='
\echo 'ANDINA DB - Iniciando instalación'
\echo 'Fecha: ' 
\! date
\echo 'Usuario: ' 
\! whoami
\echo 'Directorio: ' 
\! pwd
\echo 'PostgreSQL Version: '
SELECT version();
\echo '====================================================='

-- =====================================================
-- 1. CREACIÓN DE BASE DE DATOS Y ESQUEMA
-- =====================================================

-- Crear base de datos
\echo 'Creando base de datos dbandina...'
DROP DATABASE IF EXISTS dbandina;
CREATE DATABASE dbandina
    WITH 
    ENCODING = 'UTF8'
    LC_COLLATE = 'C'
    LC_CTYPE = 'C'
    TEMPLATE = template0;

\echo 'Base de datos creada exitosamente.'

-- Conectar a la base de datos creada
\echo 'Conectando a la base de datos dbandina...'
\c dbandina;

-- Crear esquema principal
\echo 'Creando esquema ventas...'
CREATE SCHEMA IF NOT EXISTS ventas 
    AUTHORIZATION CURRENT_USER;

\echo 'Esquema ventas creado exitosamente.'

-- Establecer esquema por defecto
SET search_path TO ventas, public;

-- =====================================================
-- 2. CREACIÓN DE TABLAS CON RESTRICCIONES
-- =====================================================

\echo 'Iniciando creación de tablas...'

-- =====================================================
-- 2.1 Tabla: clientes
-- =====================================================
\echo 'Creando tabla clientes...'
DROP TABLE IF EXISTS ventas.clientes CASCADE;
CREATE TABLE ventas.clientes (
    cliente_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    pais_iso2 CHAR(2) NOT NULL,
    fecha_registro TIMESTAMP NOT NULL DEFAULT NOW(),
    estado CHAR(1) NOT NULL DEFAULT 'A',
    telefono VARCHAR(30) NOT NULL DEFAULT 'N/D',
    
    -- Restricciones
    CONSTRAINT clientes_email_unico UNIQUE (email),
    CONSTRAINT clientes_estado_chk CHECK (estado IN ('A', 'I')),
    CONSTRAINT clientes_pais_chk CHECK (pais_iso2 ~ '^[A-Z]{2}$'),
    CONSTRAINT clientes_nombres_chk CHECK (LENGTH(TRIM(nombres)) > 0),
    CONSTRAINT clientes_apellidos_chk CHECK (LENGTH(TRIM(apellidos)) > 0),
    CONSTRAINT clientes_email_chk CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Comentarios en tabla y columnas
COMMENT ON TABLE ventas.clientes IS 'Información de clientes del sistema de ventas';
COMMENT ON COLUMN ventas.clientes.cliente_id IS 'Identificador único del cliente (autoincremental)';
COMMENT ON COLUMN ventas.clientes.nombres IS 'Nombres del cliente';
COMMENT ON COLUMN ventas.clientes.apellidos IS 'Apellidos del cliente';
COMMENT ON COLUMN ventas.clientes.email IS 'Correo electrónico único del cliente';
COMMENT ON COLUMN ventas.clientes.pais_iso2 IS 'Código ISO2 del país del cliente';
COMMENT ON COLUMN ventas.clientes.fecha_registro IS 'Fecha y hora de registro del cliente';
COMMENT ON COLUMN ventas.clientes.estado IS 'Estado del cliente: A=Activo, I=Inactivo';
COMMENT ON COLUMN ventas.clientes.telefono IS 'Número de teléfono del cliente';

\echo 'Tabla clientes creada exitosamente.'

-- =====================================================
-- 2.2 Tabla: productos
-- =====================================================
\echo 'Creando tabla productos...'
DROP TABLE IF EXISTS ventas.productos CASCADE;
CREATE TABLE ventas.productos (
    producto_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sku VARCHAR(50) NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    categoria VARCHAR(100) NOT NULL,
    precio NUMERIC(12,2) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT NOW(),
    
    -- Restricciones
    CONSTRAINT productos_sku_unico UNIQUE (sku),
    CONSTRAINT productos_precio_chk CHECK (precio >= 0),
    CONSTRAINT productos_titulo_chk CHECK (LENGTH(TRIM(titulo)) > 0),
    CONSTRAINT productos_categoria_chk CHECK (LENGTH(TRIM(categoria)) > 0),
    CONSTRAINT productos_sku_chk CHECK (LENGTH(TRIM(sku)) > 0)
);

-- Comentarios en tabla y columnas
COMMENT ON TABLE ventas.productos IS 'Catálogo de productos (libros) disponibles para venta';
COMMENT ON COLUMN ventas.productos.producto_id IS 'Identificador único del producto (autoincremental)';
COMMENT ON COLUMN ventas.productos.sku IS 'Código único del producto (Stock Keeping Unit)';
COMMENT ON COLUMN ventas.productos.titulo IS 'Título del libro/producto';
COMMENT ON COLUMN ventas.productos.categoria IS 'Categoría del producto';
COMMENT ON COLUMN ventas.productos.precio IS 'Precio del producto en soles';
COMMENT ON COLUMN ventas.productos.activo IS 'Indica si el producto está disponible para venta';
COMMENT ON COLUMN ventas.productos.fecha_creacion IS 'Fecha de creación del producto en el sistema';

\echo 'Tabla productos creada exitosamente.'

-- =====================================================
-- 2.3 Tabla: pedidos
-- =====================================================
\echo 'Creando tabla pedidos...'
DROP TABLE IF EXISTS ventas.pedidos CASCADE;
CREATE TABLE ventas.pedidos (
    pedido_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cliente_id BIGINT NOT NULL,
    fecha_pedido DATE NOT NULL DEFAULT CURRENT_DATE,
    estado TEXT NOT NULL DEFAULT 'PENDIENTE',
    fecha_actualizacion TIMESTAMP NOT NULL DEFAULT NOW(),
    
    -- Restricciones
    CONSTRAINT pedidos_cliente_fk FOREIGN KEY (cliente_id)
        REFERENCES ventas.clientes (cliente_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT pedidos_estado_chk CHECK (estado IN ('PENDIENTE', 'PAGADO', 'ENVIADO', 'CANCELADO'))
);

-- Comentarios en tabla y columnas
COMMENT ON TABLE ventas.pedidos IS 'Pedidos realizados por los clientes';
COMMENT ON COLUMN ventas.pedidos.pedido_id IS 'Identificador único del pedido (autoincremental)';
COMMENT ON COLUMN ventas.pedidos.cliente_id IS 'Referencia al cliente que realizó el pedido';
COMMENT ON COLUMN ventas.pedidos.fecha_pedido IS 'Fecha en que se realizó el pedido';
COMMENT ON COLUMN ventas.pedidos.estado IS 'Estado actual del pedido';
COMMENT ON COLUMN ventas.pedidos.fecha_actualizacion IS 'Última fecha de actualización del pedido';

\echo 'Tabla pedidos creada exitosamente.'

-- =====================================================
-- 2.4 Tabla: items_pedido
-- =====================================================
\echo 'Creando tabla items_pedido...'
DROP TABLE IF EXISTS ventas.items_pedido CASCADE;
CREATE TABLE ventas.items_pedido (
    item_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pedido_id BIGINT NOT NULL,
    producto_id BIGINT NOT NULL,
    cantidad INTEGER NOT NULL,
    precio_unitario NUMERIC(12,2) NOT NULL,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT NOW(),
    
    -- Restricciones
    CONSTRAINT items_pedido_pedido_fk FOREIGN KEY (pedido_id)
        REFERENCES ventas.pedidos (pedido_id)
        ON UPDATE RESTRICT
        ON DELETE CASCADE,
    CONSTRAINT items_pedido_producto_fk FOREIGN KEY (producto_id)
        REFERENCES ventas.productos (producto_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT items_cantidad_chk CHECK (cantidad > 0),
    CONSTRAINT items_precio_chk CHECK (precio_unitario >= 0),
    CONSTRAINT items_unicos UNIQUE (pedido_id, producto_id)
);

-- Comentarios en tabla y columnas
COMMENT ON TABLE ventas.items_pedido IS 'Items individuales dentro de cada pedido';
COMMENT ON COLUMN ventas.items_pedido.item_id IS 'Identificador único del item (autoincremental)';
COMMENT ON COLUMN ventas.items_pedido.pedido_id IS 'Referencia al pedido al que pertenece el item';
COMMENT ON COLUMN ventas.items_pedido.producto_id IS 'Referencia al producto del item';
COMMENT ON COLUMN ventas.items_pedido.cantidad IS 'Cantidad del producto en el item';
COMMENT ON COLUMN ventas.items_pedido.precio_unitario IS 'Precio unitario del producto al momento del pedido';
COMMENT ON COLUMN ventas.items_pedido.fecha_creacion IS 'Fecha de creación del item';

\echo 'Tabla items_pedido creada exitosamente.'

-- =====================================================
-- 3. CREACIÓN DE ÍNDICES PARA OPTIMIZACIÓN
-- =====================================================

\echo 'Creando índices para optimización...'

-- Índices para búsquedas frecuentes
CREATE INDEX IF NOT EXISTS idx_clientes_email ON ventas.clientes (email);
CREATE INDEX IF NOT EXISTS idx_clientes_pais ON ventas.clientes (pais_iso2);
CREATE INDEX IF NOT EXISTS idx_clientes_estado ON ventas.clientes (estado);

CREATE INDEX IF NOT EXISTS idx_productos_sku ON ventas.productos (sku);
CREATE INDEX IF NOT EXISTS idx_productos_categoria ON ventas.productos (categoria);
CREATE INDEX IF NOT EXISTS idx_productos_activo ON ventas.productos (activo);

CREATE INDEX IF NOT EXISTS idx_pedidos_cliente ON ventas.pedidos (cliente_id);
CREATE INDEX IF NOT EXISTS idx_pedidos_fecha ON ventas.pedidos (fecha_pedido);
CREATE INDEX IF NOT EXISTS idx_pedidos_estado ON ventas.pedidos (estado);

CREATE INDEX IF NOT EXISTS idx_items_pedido ON ventas.items_pedido (pedido_id);
CREATE INDEX IF NOT EXISTS idx_items_producto ON ventas.items_pedido (producto_id);

\echo 'Índices creados exitosamente.'

-- =====================================================
-- 4. INSERCIÓN DE DATOS DE PRUEBA
-- =====================================================

\echo 'Iniciando inserción de datos de prueba...'

-- =====================================================
-- 4.1 Insertar clientes
-- =====================================================
\echo 'Insertando clientes...'
INSERT INTO ventas.clientes (nombres, apellidos, email, pais_iso2, telefono)
VALUES
    ('Ana', 'Ríos', 'ana.rios@example.com', 'PE', '555-0001'),
    ('Luis', 'Paredes', 'luis.paredes@example.com', 'CL', '555-0002'),
    ('María', 'García', 'maria.garcia@example.com', 'MX', '555-0003'),
    ('José', 'Quispe', 'jose.quispe@example.com', 'PE', '555-0004')
ON CONFLICT (email) DO NOTHING;

\echo 'Clientes insertados exitosamente.'

-- =====================================================
-- 4.2 Insertar productos
-- =====================================================
\echo 'Insertando productos...'
INSERT INTO ventas.productos (sku, titulo, categoria, precio)
VALUES
    ('BK-ML-001', 'Introducción al Machine Learning', 'Tecnología', 120.00),
    ('BK-SQL-101', 'SQL para Ciencia de Datos', 'Tecnología', 90.00),
    ('BK-IA-202', 'Fundamentos de IA', 'Tecnología', 150.00),
    ('BK-NOV-01', 'Novela Histórica Andina', 'Literatura', 60.00),
    ('BK-DS-303', 'Data Science Avanzado', 'Tecnología', 200.00)
ON CONFLICT (sku) DO NOTHING;

\echo 'Productos insertados exitosamente.'

-- =====================================================
-- 4.3 Insertar pedidos e items
-- =====================================================
\echo 'Insertando pedidos e items...'

-- Pedido 1 (cliente Ana)
INSERT INTO ventas.pedidos (cliente_id, estado) 
VALUES (1, 'PAGADO') 
RETURNING pedido_id;

INSERT INTO ventas.items_pedido (pedido_id, producto_id, cantidad, precio_unitario)
VALUES
    (1, 1, 1, 120.00),
    (1, 2, 1, 90.00)
ON CONFLICT (pedido_id, producto_id) DO NOTHING;

-- Pedido 2 (cliente Luis)
INSERT INTO ventas.pedidos (cliente_id, estado) 
VALUES (2, 'PENDIENTE') 
RETURNING pedido_id;

INSERT INTO ventas.items_pedido (pedido_id, producto_id, cantidad, precio_unitario)
VALUES
    (2, 3, 1, 150.00),
    (2, 4, 2, 60.00)
ON CONFLICT (pedido_id, producto_id) DO NOTHING;

-- Pedido 3 (cliente María)
INSERT INTO ventas.pedidos (cliente_id, estado) 
VALUES (3, 'PAGADO') 
RETURNING pedido_id;

INSERT INTO ventas.items_pedido (pedido_id, producto_id, cantidad, precio_unitario)
VALUES
    (3, 5, 1, 200.00)
ON CONFLICT (pedido_id, producto_id) DO NOTHING;

\echo 'Pedidos e items insertados exitosamente.'

-- =====================================================
-- 5. CONSULTAS DE VERIFICACIÓN
-- =====================================================

\echo 'Verificando datos insertados...'

-- Verificar datos insertados
SELECT 'Clientes' AS tabla, COUNT(*) AS registros FROM ventas.clientes
UNION ALL
SELECT 'Productos' AS tabla, COUNT(*) AS registros FROM ventas.productos
UNION ALL
SELECT 'Pedidos' AS tabla, COUNT(*) AS registros FROM ventas.pedidos
UNION ALL
SELECT 'Items Pedido' AS tabla, COUNT(*) AS registros FROM ventas.items_pedido;

-- =====================================================
-- 6. CONSULTAS DE EJEMPLO
-- =====================================================

-- =====================================================
-- 6.1 Consultas básicas
-- =====================================================

-- Clientes de Perú
SELECT cliente_id, nombres, apellidos, email
FROM ventas.clientes
WHERE pais_iso2 = 'PE'
ORDER BY cliente_id;

-- Productos de tecnología con precio >= 100
SELECT producto_id, titulo, precio
FROM ventas.productos
WHERE categoria = 'Tecnología' AND precio >= 100
ORDER BY precio DESC;

-- =====================================================
-- 6.2 Consultas con JOINs
-- =====================================================

-- Vista completa de pedidos
SELECT 
    ip.item_id,
    p.pedido_id,
    c.nombres || ' ' || c.apellidos AS cliente,
    pr.titulo AS producto,
    ip.cantidad,
    ip.precio_unitario,
    (ip.cantidad * ip.precio_unitario) AS subtotal,
    p.estado
FROM ventas.items_pedido ip
JOIN ventas.pedidos p ON p.pedido_id = ip.pedido_id
JOIN ventas.clientes c ON c.cliente_id = p.cliente_id
JOIN ventas.productos pr ON pr.producto_id = ip.producto_id
ORDER BY p.pedido_id, ip.item_id;

-- =====================================================
-- 6.3 Agregaciones
-- =====================================================

-- Ingresos por pedido
SELECT 
    p.pedido_id,
    SUM(ip.cantidad * ip.precio_unitario) AS total_pedido
FROM ventas.pedidos p
JOIN ventas.items_pedido ip ON ip.pedido_id = p.pedido_id
GROUP BY p.pedido_id
ORDER BY p.pedido_id;

-- Ingresos por cliente (solo quienes superan S/ 200)
SELECT 
    c.cliente_id,
    c.nombres || ' ' || c.apellidos AS cliente,
    SUM(ip.cantidad * ip.precio_unitario) AS total_cliente
FROM ventas.clientes c
JOIN ventas.pedidos p ON p.cliente_id = c.cliente_id
JOIN ventas.items_pedido ip ON ip.pedido_id = p.pedido_id
GROUP BY c.cliente_id, cliente
HAVING SUM(ip.cantidad * ip.precio_unitario) > 200
ORDER BY total_cliente DESC;

-- =====================================================
-- 7. FUNCIONES Y PROCEDIMIENTOS DE UTILIDAD
-- =====================================================

\echo 'Creando funciones de utilidad...'

-- Función para calcular total de pedido
CREATE OR REPLACE FUNCTION ventas.calcular_total_pedido(p_pedido_id BIGINT)
RETURNS NUMERIC(12,2) AS $$
BEGIN
    RETURN (
        SELECT COALESCE(SUM(cantidad * precio_unitario), 0)
        FROM ventas.items_pedido
        WHERE pedido_id = p_pedido_id
    );
END;
$$ LANGUAGE plpgsql;

-- Comentario en la función
COMMENT ON FUNCTION ventas.calcular_total_pedido(BIGINT) IS 'Calcula el total de un pedido sumando todos sus items';

\echo 'Función creada exitosamente.'

-- =====================================================
-- 8. VISTAS ÚTILES
-- =====================================================

\echo 'Creando vistas útiles...'

-- Vista de resumen de pedidos
DROP VIEW IF EXISTS ventas.vista_resumen_pedidos CASCADE;
CREATE VIEW ventas.vista_resumen_pedidos AS
SELECT 
    p.pedido_id,
    c.nombres || ' ' || c.apellidos AS cliente,
    c.email,
    c.pais_iso2,
    p.fecha_pedido,
    p.estado,
    COUNT(ip.item_id) AS total_items,
    SUM(ip.cantidad) AS total_cantidad,
    SUM(ip.cantidad * ip.precio_unitario) AS total_pedido
FROM ventas.pedidos p
JOIN ventas.clientes c ON c.cliente_id = p.cliente_id
LEFT JOIN ventas.items_pedido ip ON ip.pedido_id = p.pedido_id
GROUP BY p.pedido_id, c.cliente_id, c.nombres, c.apellidos, c.email, c.pais_iso2, p.fecha_pedido, p.estado;

COMMENT ON VIEW ventas.vista_resumen_pedidos IS 'Vista que muestra un resumen completo de cada pedido';

\echo 'Vista creada exitosamente.'

-- =====================================================
-- 9. SCRIPT DE LIMPIEZA (OPCIONAL)
-- =====================================================

-- Descomentar las siguientes líneas para eliminar todo el esquema
-- DROP SCHEMA IF EXISTS ventas CASCADE;
-- DROP DATABASE IF EXISTS dbandina;

-- =====================================================
-- FIN DEL SCRIPT
-- =====================================================

-- Mensaje de finalización
\echo '====================================================='
\echo 'ANDINA DB - Instalación completada exitosamente'
\echo 'Base de datos: dbandina'
\echo 'Esquema: ventas'
\echo 'Tablas creadas: 4'
\echo 'Datos de prueba insertados: Sí'
\echo 'Fecha de finalización: ' 
\! date
\echo '====================================================='

-- Cerrar spool de logging
\o

-- Mensaje final
\echo 'Log guardado en: logs/andina_db_install_*.log'
\echo 'Instalación completada. Revisar el log para detalles.'