\echo '=== Camilo Angulo | LAB-01 | Verificacion final ==='
SELECT now();

\echo '##### SOPORTE #####'
SET ROLE soporte;
SELECT * FROM v_clientes_soporte;
SELECT * FROM clientes;
RESET ROLE;

\echo '##### ANALISTA #####'
SET ROLE analista;
SELECT * FROM analitica.clientes;
SELECT * FROM pii.mapa_cliente;
SELECT * FROM public.clientes;
RESET ROLE;