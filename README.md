# Database Projects

Este repositorio contiene proyectos de bases de datos para desarrollo y aprendizaje.

## Proyectos Disponibles

### Adventure Works Database
Base de datos de ejemplo completa que simula una empresa de manufactura de bicicletas.

**Características:**
- 68 tablas distribuidas en 5 esquemas principales
- Datos realistas de una empresa manufacturera
- Configuración Docker con PostgreSQL
- Vistas de conveniencia para consultas simplificadas

**Documentación completa:** [adventure-works/README.md](./adventure-works/README.md)

**Inicio rápido:**
```bash
cd adventure-works
docker compose up -d
```

**Conexión:**
- Host: `localhost`
- Puerto: `5432`
- Usuario: `postgres`
- Contraseña: `postgres`
- Base de datos: `adventureworks`

## Requisitos Generales
- Docker y Docker Compose
- Cliente de base de datos (DBeaver, pgAdmin, etc.)
- WSL2 (para entornos Windows)

## Estructura del Repositorio
```
database/
├── README.md                    # Este archivo
├── adventure-works/             # Base de datos Adventure Works
│   ├── README.md               # Documentación completa
│   ├── docker-compose.yml       # Configuración Docker
│   ├── Dockerfile              # Imagen personalizada
│   └── 01_install.sql          # Script de instalación
└── LICENSE                      # Licencia del proyecto
```

## Contribuciones
Para agregar nuevos proyectos de base de datos:
1. Crear nueva carpeta con nombre descriptivo
2. Incluir documentación completa en README.md
3. Actualizar este README principal
4. Seguir las mejores prácticas de Docker y documentación