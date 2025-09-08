# Adventure Works Database - Guía de Instalación y Conexión

## Descripción
Adventure Works es una base de datos de ejemplo completa que simula una empresa de manufactura de bicicletas. Contiene 68 tablas distribuidas en 5 esquemas principales con datos realistas.

## Requisitos Previos
- Docker instalado y funcionando
- Docker Compose (versión moderna: `docker compose`)
- Cliente PostgreSQL (opcional, para conexión desde terminal)
- DBeaver o cualquier cliente de base de datos compatible

## Instalación y Configuración

### 1. Verificar Docker
```bash
docker --version
docker compose version
```

### 2. Levantar la Base de Datos
```bash
# Navegar al directorio
cd adventure-works

# Levantar el contenedor en segundo plano
docker compose up -d
```

### 3. Verificar que el Contenedor Esté Ejecutándose
```bash
# Ver estado de contenedores
docker compose ps

# Ver logs del contenedor (opcional)
docker logs pg-aw
```

## Configuración de Conexión

### Parámetros de Conexión
- **Host**: `localhost`
- **Puerto**: `5432`
- **Base de datos**: `adventureworks`
- **Usuario**: `postgres`
- **Contraseña**: `postgres`

## Conexión desde DBeaver

### 1. Crear Nueva Conexión
1. Abrir DBeaver
2. Clic en "Nueva Conexión" (icono de enchufe)
3. Seleccionar "PostgreSQL"

### 2. Configurar Parámetros
En la pestaña **Main**:
- **Host**: `localhost`
- **Port**: `5432`
- **Database**: `adventureworks`
- **Username**: `postgres`
- **Password**: `postgres`
- **Save password**: ✅ Activado

### 3. Probar Conexión
1. Clic en "Test Connection..."
2. Debería mostrar "Connected" con tiempo de respuesta
3. Clic en "OK" y luego "Finish"

## Conexión desde Terminal

### Instalar Cliente PostgreSQL (Ubuntu/WSL2)
```bash
sudo apt update
sudo apt install -y postgresql-client
```

### Conectarse
```bash
# Método 1: Con variable de entorno
PGPASSWORD=postgres psql -h localhost -p 5432 -U postgres -d adventureworks

# Método 2: Con URL de conexión
psql postgresql://postgres:postgres@localhost:5432/adventureworks

# Método 3: Sin especificar contraseña (te la pedirá)
psql -h localhost -p 5432 -U postgres -d adventureworks
```

## Estructura de la Base de Datos

### Esquemas Principales
- **Person**: Información de personas y contactos (13 tablas)
- **HumanResources**: Empleados y departamentos (6 tablas)
- **Production**: Productos y manufactura (25 tablas)
- **Purchasing**: Compras y proveedores (5 tablas)
- **Sales**: Ventas y clientes (19 tablas)

### Vistas de Conveniencia
Cada esquema tiene vistas abreviadas:
- **pe**: person (p, a, be, e, etc.)
- **hr**: humanresources (e, d, s, etc.)
- **pr**: production (p, pc, pm, etc.)
- **pu**: purchasing (poh, pod, v, etc.)
- **sa**: sales (soh, sod, c, etc.)

## Comandos Útiles

### Gestión del Contenedor
```bash
# Apagar contenedor
docker compose down

# Apagar y eliminar volúmenes (borra datos)
docker compose down -v

# Reiniciar contenedor
docker compose restart

# Ver logs
docker logs pg-aw
```

### Consultas de Exploración
```sql
-- Ver esquemas
\dn

-- Ver tablas por esquema
\dt person.*
\dt sales.*
\dt production.*

-- Ver vistas de conveniencia
\dv pe.*
\dv hr.*

-- Ver estructura de tabla
\d person.person
```

## Consultas de Ejemplo

### Explorar Datos Básicos
```sql
-- Ver personas
SELECT firstname, lastname, persontype 
FROM person.person 
LIMIT 10;

-- Ver productos
SELECT name, productnumber, listprice 
FROM production.product 
WHERE listprice > 0 
ORDER BY listprice DESC 
LIMIT 10;

-- Ver empleados con nombres
SELECT e.businessentityid, p.firstname, p.lastname, e.jobtitle
FROM humanresources.employee e
JOIN person.person p ON e.businessentityid = p.businessentityid
LIMIT 10;
```

### Usar Vistas de Conveniencia
```sql
-- Más simple con vistas abreviadas
SELECT pe.p.firstname, pe.p.lastname, hr.e.jobtitle
FROM pe.p
JOIN hr.e ON pe.p.id = hr.e.id
LIMIT 10;
```

## Solución de Problemas

### Error de Autenticación
Si obtienes "password authentication failed":
1. Verificar que el contenedor esté ejecutándose: `docker compose ps`
2. Reiniciar el contenedor: `docker compose down && docker compose up -d`
3. Verificar configuración en `docker-compose.yml`

### Puerto en Uso
Si el puerto 5432 está ocupado:
1. Cambiar puerto en `docker-compose.yml`
2. Actualizar configuración de conexión en DBeaver

### Problemas de Red en WSL2
Si hay problemas de conectividad:
1. Usar `127.0.0.1` en lugar de `localhost`
2. **Usar el IP específico de WSL2**: `wsl hostname -I` (comando que devuelve el IP de WSL2)
3. Verificar que Docker Desktop tenga WSL2 integration activada

**Verificar que el contenedor esté accesible:**

**Desde WSL2:**
```bash
# Instalar herramientas de red (si no están disponibles)
sudo apt install inetutils-telnet
sudo apt install telnet-ssl

# Verificar que el puerto esté abierto
netstat -tlnp | grep 5432

# Verificar conectividad desde WSL2
telnet localhost 5432
```

**Desde Windows (Host con DBeaver):**
```cmd
# Activar telnet en Windows (como Administrador)
dism /online /Enable-Feature /FeatureName:TelnetClient

# O usando PowerShell (como Administrador)
Enable-WindowsOptionalFeature -Online -FeatureName TelnetClient

# Verificar conectividad desde Windows
telnet localhost 5432
```

**¿Por qué funciona el IP de WSL2?**
- WSL2 crea una interfaz de red virtualizada
- `localhost` puede resolver a diferentes interfaces según el contexto
- El IP específico de WSL2 garantiza conectividad directa al contenedor
- Es especialmente útil cuando hay conflictos de resolución DNS entre Windows y WSL2

## Recursos Adicionales
- [Documentación oficial de Adventure Works](https://github.com/Microsoft/sql-server-samples/tree/master/samples/databases/adventure-works)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [DBeaver Documentation](https://dbeaver.com/docs/)

---
**Nota**: Esta configuración está optimizada para desarrollo y aprendizaje. Para producción, considera configuraciones de seguridad adicionales.
