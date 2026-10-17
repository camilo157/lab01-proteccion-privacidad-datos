# LAB-01: Protección y privacidad de datos

Laboratorio de la materia Gestión de Seguridad y Desempeño de Bases de Datos (Unidad II, tema 2.3).

- Estudiante: Camilo Angulo
- Materia: Gestión de Seguridad y Desempeño de Bases de Datos
- Motor: PostgreSQL 16 en Docker, 17 de octubre de 2026

## Qué contiene

- `sql/`: los scripts de cada actividad, en el orden en que se ejecutan.
- `evidencias/`: capturas de la ejecución de cada script.
- `informe.md`: clasificación de datos, explicación de cada técnica, análisis de reidentificación, retención, conclusiones y preguntas de reflexión.

## Scripts

| Archivo | Actividad |
|---|---|
| 01-clasificacion.sql | Preparación (tabla clientes y datos de prueba) y clasificación |
| 02-enmascaramiento.sql | Vista enmascarada y rol soporte |
| 03-seudonimizacion.sql | Tokens, mapa de correspondencia, rol analista y separación de funciones |
| 04-anonimizacion.sql | Generalización, agregación y umbral de grupos |
| 05-retencion.sql | Consulta de registros que superan el periodo de retención |
| 06-verificacion-final.sql | Verificación de permisos de soporte y analista |

## Cómo ejecutarlo

Levantar PostgreSQL 16:

    docker run -d --name pg-lab01 -e POSTGRES_PASSWORD=admin123 -p 5432:5432 postgres:16
    docker exec pg-lab01 mkdir -p /lab
    docker cp sql/. pg-lab01:/lab

Correr cada script en orden (01 al 06):

    docker exec -it pg-lab01 psql -U postgres -a -f /lab/01-clasificacion.sql

Los roles son NOLOGIN, así que los scripts usan SET ROLE para probar los permisos.

## Entrega

El repositorio del profesor en GitLab no estaba disponible, así que entrego las evidencias en este repositorio de GitHub.