# Andina DB - Sistema de Ventas de Librería

## Descripción
Andina DB es un sistema de base de datos diseñado para una librería/editorial especializada en libros de tecnología y literatura andina. El sistema maneja clientes, productos, pedidos y items de pedidos con un enfoque en la integridad de datos y las mejores prácticas de PostgreSQL.

## Características del Sistema

### Modelo de Datos
- **4 tablas principales** con relaciones bien definidas
- **Integridad referencial** robusta con foreign keys
- **Restricciones de negocio** implementadas con CHECK constraints
- **Identificadores únicos** autoincrementales
- **Validaciones de datos** en múltiples niveles

### Funcionalidades
- Gestión de clientes con validación de países ISO2
- Catálogo de productos con SKUs únicos
- Sistema de pedidos con estados controlados
- Items de pedido con cálculos automáticos
- Reportes de ventas por cliente y producto

### Características Técnicas Avanzadas
- **Sistema de logging automático** con archivos timestamp
- **Creación automática** del directorio de logs
- **Compatibilidad universal** con locales (LC_COLLATE = 'C')
- **Índices optimizados** para consultas frecuentes
- **Funciones PL/pgSQL** para cálculos automáticos
- **Vistas de resumen** para consultas complejas
- **Documentación completa** inline en el código
- **Manejo de errores** robusto con transacciones

## Estructura de la Base de Datos

### Esquema: `ventas`

#### 1. Tabla `clientes`
```sql
cliente_id     BIGINT      PRIMARY KEY (autoincremental)
nombres        VARCHAR(100) NOT NULL
apellidos      VARCHAR(100) NOT NULL
email          VARCHAR(255) NOT NULL UNIQUE
pais_iso2      CHAR(2)      NOT NULL
fecha_registro TIMESTAMP    NOT NULL DEFAULT NOW()
estado         CHAR(1)      NOT NULL DEFAULT 'A'
telefono       VARCHAR(30)   NOT NULL
```

**Restricciones:**
- Email único
- Estado válido: 'A' (Activo) o 'I' (Inactivo)
- País en formato ISO2 alfabético

#### 2. Tabla `productos`
```sql
producto_id BIGINT       PRIMARY KEY (autoincremental)
sku         VARCHAR(50)  NOT NULL UNIQUE
titulo      VARCHAR(200) NOT NULL
categoria   VARCHAR(100) NOT NULL
precio      NUMERIC(12,2) NOT NULL
activo      BOOLEAN      NOT NULL DEFAULT TRUE
```

**Restricciones:**
- SKU único
- Precio >= 0
- Estado activo/inactivo

#### 3. Tabla `pedidos`
```sql
pedido_id    BIGINT      PRIMARY KEY (autoincremental)
cliente_id   BIGINT      NOT NULL (FK → clientes)
fecha_pedido DATE        NOT NULL DEFAULT CURRENT_DATE
estado       TEXT        NOT NULL DEFAULT 'PENDIENTE'
```

**Restricciones:**
- Cliente válido (FK)
- Estados válidos: 'PENDIENTE', 'PAGADO', 'ENVIADO', 'CANCELADO'

#### 4. Tabla `items_pedido`
```sql
item_id          BIGINT       PRIMARY KEY (autoincremental)
pedido_id        BIGINT       NOT NULL (FK → pedidos)
producto_id      BIGINT       NOT NULL (FK → productos)
cantidad         INTEGER      NOT NULL
precio_unitario  NUMERIC(12,2) NOT NULL
```

**Restricciones:**
- Pedido y producto válidos (FK)
- Cantidad > 0
- Precio unitario >= 0
- Combinación pedido-producto única

## Relaciones

```mermaid
erDiagram
    CLIENTES {
        bigint cliente_id PK
        varchar nombres
        varchar apellidos
        varchar email UK
        char pais_iso2
        timestamp fecha_registro
        char estado
        varchar telefono
    }
    
    PRODUCTOS {
        bigint producto_id PK
        varchar sku UK
        varchar titulo
        varchar categoria
        numeric precio
        boolean activo
        timestamp fecha_creacion
    }
    
    PEDIDOS {
        bigint pedido_id PK
        bigint cliente_id FK
        date fecha_pedido
        text estado
        timestamp fecha_actualizacion
    }
    
    ITEMS_PEDIDO {
        bigint item_id PK
        bigint pedido_id FK
        bigint producto_id FK
        integer cantidad
        numeric precio_unitario
        timestamp fecha_creacion
    }
    
    CLIENTES ||--o{ PEDIDOS : "realiza"
    PEDIDOS ||--o{ ITEMS_PEDIDO : "contiene"
    PRODUCTOS ||--o{ ITEMS_PEDIDO : "incluye"
```

**Relaciones:**
- Un cliente puede tener múltiples pedidos
- Un pedido puede tener múltiples items
- Un producto puede estar en múltiples items de diferentes pedidos
- Eliminación en cascada: pedido → items_pedido

## Instalación y Configuración

### Requisitos
- PostgreSQL 12+ 
- Cliente de base de datos (psql, DBeaver, pgAdmin, etc.)

### Instalación en Linux

#### 1. Instalar PostgreSQL (Ubuntu/Debian)
```bash
# Actualizar repositorios
sudo apt update

# Instalar PostgreSQL
sudo apt install postgresql postgresql-contrib

# Instalar cliente PostgreSQL
sudo apt install postgresql-client

# Verificar instalación
psql --version
```

#### 2. Configurar PostgreSQL
```bash
# Cambiar a usuario postgres
sudo -u postgres psql

# Cambiar contraseña del usuario postgres
ALTER USER postgres PASSWORD 'tu_password';
ALTER USER postgres PASSWORD 'postgres';

# Salir de psql
\q
```

#### 3. Ejecutar el Script DDL

**Opción A: Desde línea de comandos (Recomendado)**
```bash
# Navegar al directorio del proyecto
cd /ruta/a/tu/proyecto/andina-db

# Ejecutar el script completo (método más seguro)
sudo -u postgres psql -f andina.ddl

# O con contraseña en línea de comandos
PGPASSWORD=postgres psql -U postgres -f andina.ddl

# Si tienes error de "Peer authentication failed", usar:
sudo -u postgres psql -f andina.ddl
```

**Opción B: Desde psql interactivo**
```bash
# Conectar a PostgreSQL
psql -U postgres

# Ejecutar el script
\i andina.ddl

# Verificar conexión a la nueva base de datos
\c dbandina

# Verificar tablas creadas
\dt ventas.*
```

**Opción C: Con URL de conexión**
```bash
# Ejecutar directamente con URL
psql postgresql://postgres:postgres@localhost:5432/postgres -f andina.ddl
```

**Opción D: Ejecución con logging automático**
```bash
# El script crea automáticamente el directorio logs/ y guarda todo el proceso
psql -U postgres -f andina.ddl

# Ver el log generado
ls -la logs/
cat logs/andina_db_install_*.log
```

#### 4. Verificar Instalación
```sql
-- Conectar a la base de datos creada
\c dbandina

-- Verificar esquemas
\dn

-- Verificar tablas
\dt ventas.*

-- Verificar datos
SELECT COUNT(*) FROM ventas.clientes;
SELECT COUNT(*) FROM ventas.productos;
SELECT COUNT(*) FROM ventas.pedidos;
SELECT COUNT(*) FROM ventas.items_pedido;
```

#### 5. Sistema de Logging Automático
El script incluye un sistema completo de logging que:

- **Crea automáticamente** el directorio `logs/`
- **Captura toda la salida** del script
- **Genera archivo único** con timestamp: `andina_db_install_YYYYMMDD_HHMMSS.log`
- **Registra cada paso** de la instalación
- **Incluye información del entorno** (usuario, fecha, versión PostgreSQL)

**Verificar el log:**
```bash
# Listar archivos de log
ls -la logs/

# Ver el contenido del log
cat logs/andina_db_install_*.log

# Ver las últimas líneas del log
tail -f logs/andina_db_install_*.log
```

**Ejemplo de salida esperada:**
```
=====================================================
ANDINA DB - Instalación completada exitosamente
Base de datos: dbandina
Esquema: ventas
Tablas creadas: 4
Datos de prueba insertados: Sí
Fecha de finalización: [timestamp]
=====================================================
Log guardado en: logs/andina_db_install_*.log
Instalación completada. Revisar el log para detalles.
```

### Instalación en Windows
```cmd
# Usar pgAdmin o psql desde línea de comandos
psql -U postgres -f andina.ddl
```

### Instalación con Docker
```bash
# Crear contenedor PostgreSQL
docker run --name postgres-andina \
  -e POSTGRES_PASSWORD=tu_password \
  -e POSTGRES_DB=dbandina \
  -p 5432:5432 \
  -d postgres:15

# Copiar script al contenedor
docker cp andina.ddl postgres-andina:/tmp/

# Ejecutar script
docker exec -i postgres-andina psql -U postgres -d dbandina -f /tmp/andina.ddl
```

## Solución de Problemas

### Problemas Comunes y Soluciones

#### **Problema: Errores de permisos y locale**

Si encuentras estos errores al ejecutar el script:
```
mkdir: cannot create directory 'logs': Permission denied
ERROR: invalid LC_COLLATE locale name: "es_ES.UTF-8"
```

**Solución completa:**
```bash
# 1. Crear directorio logs con permisos correctos
sudo mkdir -p logs
sudo chown postgres:postgres logs
sudo chmod 755 logs

# 2. Limpiar base de datos si existe
sudo -u postgres psql -c "DROP DATABASE IF EXISTS dbandina;"

# 3. Ejecutar script corregido
sudo -u postgres psql -f andina.ddl
```

### Error: "Peer authentication failed for user postgres"

Este error ocurre cuando PostgreSQL está configurado con autenticación peer. **Soluciones:**

#### **Solución 1: Usar sudo (Recomendado)**
```bash
# Ejecutar como usuario postgres del sistema
sudo -u postgres psql -f andina.ddl
```

#### **Solución 2: Conectar por TCP**
```bash
# Especificar host y puerto para usar TCP en lugar de socket Unix
PGPASSWORD=postgres psql -h localhost -p 5432 -U postgres -f andina.ddl
```

#### **Solución 3: Cambiar método de autenticación**
```bash
# Editar configuración de PostgreSQL
sudo nano /etc/postgresql/*/main/pg_hba.conf

# Buscar la línea:
# local   all             postgres                                peer
# Cambiarla por:
# local   all             postgres                                md5

# Reiniciar PostgreSQL
sudo systemctl restart postgresql

# Luego ejecutar normalmente
PGPASSWORD=postgres psql -U postgres -f andina.ddl
```

### Error: "Database dbandina already exists"

Si la base de datos ya existe:
```bash
# Eliminar base de datos existente
sudo -u postgres psql -c "DROP DATABASE IF EXISTS dbandina;"

# Ejecutar script nuevamente
sudo -u postgres psql -f andina.ddl
```

### Error: "Permission denied" al crear directorio logs

Si no tienes permisos para crear el directorio:
```bash
# Crear directorio manualmente con permisos correctos
sudo mkdir -p logs
sudo chown postgres:postgres logs
sudo chmod 755 logs

# Ejecutar script
sudo -u postgres psql -f andina.ddl
```

### Error: "invalid LC_COLLATE locale name: es_ES.UTF-8"

Este error ocurre cuando el locale especificado no está disponible en el sistema:

#### **Solución 1: Verificar locales disponibles**
```bash
# Ver locales instalados
locale -a | grep -i es
locale -a | grep -i utf
```

#### **Solución 2: Instalar locale español (opcional)**
```bash
# Instalar locale español
sudo apt install locales
sudo locale-gen es_ES.UTF-8
sudo update-locale LANG=es_ES.UTF-8
```

#### **Solución 3: Usar locale por defecto (Recomendado)**
El script ya está configurado para usar `LC_COLLATE = 'C'` y `LC_CTYPE = 'C'` que son compatibles con todos los sistemas.

### Error: "database dbandina does not exist"

Si la base de datos no se creó debido a errores previos:
```bash
# Limpiar y ejecutar nuevamente
sudo -u postgres psql -c "DROP DATABASE IF EXISTS dbandina;"
sudo -u postgres psql -f andina.ddl
```

### Problema: Archivo de log con nombre literal "$(date"

Si ves un archivo de log con nombre `andina_db_install_$(date` en lugar de la fecha real:

**Causa:** psql no interpreta sustituciones de shell como `$(date +%Y%m%d_%H%M%S)`

**Solución:** El script ya está corregido para usar:
```sql
\o | cat > "logs/andina_db_install_$(date +%Y%m%d_%H%M%S).log"
```

**Para limpiar archivos de log incorrectos:**
```bash
# Eliminar archivos de log con nombres incorrectos
rm -f logs/andina_db_install_\$\(date*

# Ejecutar script corregido
sudo -u postgres psql -f andina.ddl
```

### Verificación
```sql
-- Verificar tablas creadas
\dt ventas.*

-- Verificar datos de ejemplo
SELECT COUNT(*) FROM ventas.clientes;
SELECT COUNT(*) FROM ventas.productos;
SELECT COUNT(*) FROM ventas.pedidos;
SELECT COUNT(*) FROM ventas.items_pedido;
```

## Consultas de Ejemplo

### Consultas Básicas
```sql
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
```

### Consultas con JOINs
```sql
-- Vista completa de pedidos
SELECT ip.item_id,
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
```

### Agregaciones
```sql
-- Ingresos por cliente (solo quienes superan S/ 200)
SELECT c.cliente_id,
       c.nombres || ' ' || c.apellidos AS cliente,
       SUM(ip.cantidad * ip.precio_unitario) AS total_cliente
FROM ventas.clientes c
JOIN ventas.pedidos p ON p.cliente_id = c.cliente_id
JOIN ventas.items_pedido ip ON ip.pedido_id = p.pedido_id
GROUP BY c.cliente_id, cliente
HAVING SUM(ip.cantidad * ip.precio_unitario) > 200
ORDER BY total_cliente DESC;
```

## Operaciones DML

### INSERT
```sql
-- Insertar nuevo cliente
INSERT INTO ventas.clientes (nombres, apellidos, email, pais_iso2, telefono)
VALUES ('Carlos', 'Mendoza', 'carlos.mendoza@example.com', 'CO', '555-0123')
RETURNING *;
```

### UPDATE
```sql
-- Actualizar precio de producto
UPDATE ventas.productos
SET precio = precio * 1.10
WHERE sku = 'BK-SQL-101'
RETURNING producto_id, sku, precio;
```

### DELETE (con transacción)
```sql
BEGIN;
DELETE FROM ventas.pedidos WHERE pedido_id = 2;
-- Los items se eliminan automáticamente por CASCADE
COMMIT;
```

## Buenas Prácticas Implementadas

### Integridad de Datos
- **Primary Keys** autoincrementales para identificadores únicos
- **Foreign Keys** con restricciones ON DELETE CASCADE/RESTRICT
- **UNIQUE constraints** para campos críticos (email, SKU)
- **CHECK constraints** para validaciones de negocio
- **NOT NULL** para campos obligatorios

### Seguridad
- **Transacciones** para operaciones críticas
- **RETURNING** para confirmar cambios
- **WHERE específicos** en UPDATE/DELETE
- **Validación previa** con SELECT

### Mantenibilidad
- **Nombres descriptivos** para tablas y columnas
- **Comentarios** en el código
- **Estructura modular** del script
- **Datos de prueba** incluidos

## Casos de Uso

### E-commerce
- Gestión de catálogo de productos
- Procesamiento de pedidos
- Control de inventario
- Reportes de ventas

### Análisis de Negocio
- Ventas por cliente
- Productos más vendidos
- Ingresos por período
- Análisis geográfico (por país)

### Administración
- Gestión de clientes
- Control de estados de pedidos
- Actualización de precios
- Mantenimiento de datos

## Datos de Ejemplo

El sistema incluye datos de prueba:
- **4 clientes** de diferentes países (PE, CL, MX)
- **5 productos** de tecnología y literatura
- **3 pedidos** con diferentes estados
- **Items de pedido** con cálculos de subtotales

## Extensibilidad

### Posibles Mejoras
- Tabla de categorías normalizada
- Sistema de descuentos
- Historial de cambios de precios
- Auditoría de transacciones
- Integración con sistemas de pago

### Escalabilidad
- Índices en campos de búsqueda frecuente
- Particionamiento por fecha
- Replicación para alta disponibilidad
- Optimización de consultas complejas

## Soporte

Para consultas o mejoras al sistema, revisar:
- Documentación de PostgreSQL
- Mejores prácticas de diseño de bases de datos
- Patrones de integridad referencial

## Mejoras Implementadas en el Script

### Sistema de Logging Profesional
- **Creación automática** del directorio `logs/`
- **Archivos de log** con timestamp único: `andina_db_install_YYYYMMDD_HHMMSS.log`
- **Captura completa** de toda la salida del script
- **Información del entorno** (usuario, fecha, versión PostgreSQL)
- **Seguimiento paso a paso** de cada operación

### Compatibilidad Universal
- **Locale por defecto** (`LC_COLLATE = 'C'`) compatible con todos los sistemas
- **Eliminación de dependencias** de locales específicos
- **Funcionamiento garantizado** en cualquier instalación de PostgreSQL

### Manejo de Errores Robusto
- **Transacciones** para operaciones críticas
- **Validaciones previas** antes de operaciones destructivas
- **Mensajes informativos** en cada paso del proceso
- **Rollback automático** en caso de errores

### Optimizaciones de Rendimiento
- **Índices estratégicos** en campos de búsqueda frecuente
- **Funciones PL/pgSQL** para cálculos optimizados
- **Vistas materializadas** para consultas complejas
- **Restricciones eficientes** con validaciones rápidas

### Documentación Completa
- **Comentarios inline** en todas las tablas y columnas
- **Documentación de funciones** y vistas
- **Ejemplos de uso** incluidos en el script
- **Guía de troubleshooting** en el README

---
**Versión**: 1.1  
**Última actualización**: 2024  
**Compatibilidad**: PostgreSQL 12+  
**Mejoras**: Sistema de logging, compatibilidad universal, manejo de errores robusto
