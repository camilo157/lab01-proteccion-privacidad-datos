\echo '=== Camilo Angulo | LAB-01 | Act. 5 y 6: Anonimizacion ==='
SELECT now();

\echo '--- 12.1 Rango de edad ---'
SELECT CASE WHEN edad BETWEEN 18 AND 30 THEN '18-30'
            WHEN edad BETWEEN 31 AND 45 THEN '31-45'
            ELSE '46+' END AS rango_edad,
       COUNT(*) AS total
FROM clientes GROUP BY 1;

\echo '--- 12.2 Region ---'
SELECT LEFT(codigo_postal, 2) AS region, COUNT(*) AS total
FROM clientes GROUP BY 1;

\echo '--- 12.3 Combinado ---'
SELECT CASE WHEN edad BETWEEN 18 AND 30 THEN '18-30'
            WHEN edad BETWEEN 31 AND 45 THEN '31-45'
            ELSE '46+' END AS rango_edad,
       LEFT(codigo_postal, 2) AS region,
       COUNT(*) AS total
FROM clientes GROUP BY 1, 2;

\echo '--- 12.4 Con umbral >= 5 (se espera 0 filas) ---'
SELECT CASE WHEN edad BETWEEN 18 AND 30 THEN '18-30'
            WHEN edad BETWEEN 31 AND 45 THEN '31-45'
            ELSE '46+' END AS rango_edad,
       LEFT(codigo_postal, 2) AS region,
       COUNT(*) AS total
FROM clientes GROUP BY 1, 2
HAVING COUNT(*) >= 5;

\echo '--- RETO: sin region, rangos mas amplios, umbral 3 ---'
SELECT CASE WHEN edad < 40 THEN 'menos de 40' ELSE '40+' END AS rango_edad,
       COUNT(*) AS total
FROM clientes GROUP BY 1
HAVING COUNT(*) >= 3;