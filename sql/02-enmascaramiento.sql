\echo '=== Camilo Angulo | LAB-01 | Act. 2: Enmascaramiento ==='
SELECT now();

CREATE ROLE soporte NOLOGIN;

CREATE VIEW v_clientes_soporte AS
SELECT
    id,
    nombre,
    CONCAT(LEFT(correo, 2), '*****', SUBSTRING(correo FROM POSITION('@' IN correo))) AS correo,
    CONCAT('******', RIGHT(telefono, 4)) AS telefono,
    CONCAT('*********', RIGHT(rfc, 4)) AS rfc
FROM clientes;

SELECT * FROM v_clientes_soporte;

GRANT USAGE ON SCHEMA public TO soporte;
GRANT SELECT ON v_clientes_soporte TO soporte;
REVOKE ALL ON clientes FROM soporte;

\echo '--- Prueba como soporte ---'
SET ROLE soporte;
SELECT current_user;
SELECT * FROM v_clientes_soporte;
SELECT * FROM clientes;
RESET ROLE;

\echo '--- Permisos aplicados ---'
\dp v_clientes_soporte
\dp clientes