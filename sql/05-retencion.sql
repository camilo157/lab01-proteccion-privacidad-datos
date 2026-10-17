\echo '=== Camilo Angulo | LAB-01 | Act. 7: Retencion ==='
SELECT now();

\echo '--- Registros con mas de 5 anios (se espera 0 filas) ---'
SELECT * FROM clientes
WHERE fecha_alta < CURRENT_DATE - INTERVAL '5 years';

\echo '--- Prueba de logica con periodo de 0 dias (solo para demostrar que la consulta funciona) ---'
SELECT id, nombre, fecha_alta FROM clientes
WHERE fecha_alta <= CURRENT_DATE - INTERVAL '0 days';