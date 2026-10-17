    # LAB-01: Protección y privacidad de datos

Camilo Angulo
Gestión de Seguridad y Desempeño de Bases de Datos
PostgreSQL 16 en Docker, 17 de octubre de 2026

Los scripts están en la carpeta sql y las capturas en evidencias. Corrí los scripts en orden con psql dentro del contenedor pg-lab01.

## 1. Clasificación

| Campo | ¿Identifica directamente? | ¿Puede contribuir a identificar? | ¿Requiere protección? | Justificación |
|---|---|---|---|---|
| id | No | Sí | Sí | Es un número interno, pero enlaza todos los datos de la persona y lo usa el mapa de tokens |
| nombre | Sí | Sí | Sí | Es el identificador más directo |
| correo | Sí | Sí | Sí | Casi siempre trae el nombre y sirve para contactar a la persona |
| telefono | Sí | Sí | Sí | Permite localizar a la persona |
| rfc | Sí | Sí | Sí | Es un dato fiscal y además trae la fecha de nacimiento (LOAA850315 es 15/03/1985) |
| edad | No | Sí | Sí | Sola no identifica, pero junto con ciudad y código postal reduce mucho el grupo |
| ciudad | No | Sí | Sí | Es amplia, pero ayuda a acotar |
| codigo_postal | No | Sí | Sí | Es más específico que la ciudad y ubica a la persona en una zona |
| fecha_alta | No | Sí, poco | Poco | No identifica, pero combinada con otros datos puede distinguir registros |

Los campos que identifican directamente a una persona son nombre, correo, teléfono y RFC. Los que no identifican solos pero pueden ayudar son edad, ciudad, código postal y la fecha de alta (el id también, porque conecta todo).

La combinación que más sube el riesgo de reidentificación es edad, ciudad y código postal. Con solo 5 clientes, esos tres datos juntos casi señalan a una sola persona.

Y no, no todo lo que se protege es dato sensible. El nombre, el correo o el teléfono son datos personales y hay que cuidarlos, pero los sensibles son los de cosas más íntimas como salud o creencias, y en esta tabla no hay ninguno.

## 2. Enmascaramiento

Para el área de soporte creé la vista v_clientes_soporte, que muestra el correo, el teléfono y el RFC a medias (por ejemplo an*****@example.test, ******4567 y *********5ABC). Soporte necesita saber de qué cliente se trata para atenderlo, pero no necesita ver todos sus datos completos.

Al rol soporte le di SELECT solo sobre la vista y le quité todos los permisos sobre la tabla clientes. Lo probé con SET ROLE soporte: la vista sí me la dejó consultar, pero cuando hice SELECT sobre clientes me salió "permission denied for table clientes", que era lo que quería ver. En el \dp de la vista aparece soporte con permiso de lectura y en el de clientes ya no aparece.

Los datos reales siguen completos en la tabla original, lo único que cambia es lo que se muestra. Por eso no basta con ocultarlos en la aplicación: si alguien se conecta directo a la base los ve todos. Si soporte tuviera acceso directo a clientes se podría saltar la vista y el enmascaramiento no serviría.

Las evidencias están en 02-enmascaramiento.

## 3. Seudonimización

Los tokens los generé con la extensión pgcrypto y la función gen_random_uuid(), que crea un UUID aleatorio por cada cliente. La relación entre token y cliente la guardé en pii.mapa_cliente, en un esquema aparte (pii), y para analítica hice la tabla analitica.clientes, que solo tiene el token, la edad, la ciudad, el código postal y la fecha de alta. No tiene nombre, correo, teléfono ni RFC, y lo revisé con \d.

El rol analista solo tiene permiso sobre analitica.clientes. Cuando probé con SET ROLE analista, esa tabla sí la pude consultar, pero pii.mapa_cliente me dio "permission denied for schema pii" y public.clientes me dio "permission denied for table clientes".

El mapa debería poder consultarlo solo el DBA o alguien autorizado para reidentificar. Separé los permisos porque si el mismo usuario puede ver los datos y el mapa, puede unir el token con el cliente_id y saber quién es cada persona, y entonces la seudonimización ya no sirve de nada. Aquí se aplica la separación de funciones y el mínimo privilegio.

La seudonimización no es anonimización porque se puede revertir con el mapa, y además edad, ciudad y código postal siguen ahí y pueden identificar a alguien. Lo que permite volver del token a la persona es la tabla pii.mapa_cliente junto con clientes.

Las evidencias están en 03-seudonimizacion.

## 4. Anonimización

Para las estadísticas no usé nombre, correo, teléfono ni RFC. La edad la convertí en rangos (18-30, 31-45 y 46+) y el código postal lo reduje a sus dos primeros dígitos, que son la región.

Los resultados fueron: 4 clientes en el rango 31-45 y 1 en 46+; 3 en la región 80, 1 en la 81 y 1 en la 82. Al combinar rango y región, el grupo más grande tiene solo 3 personas. Cuando agregué HAVING COUNT(*) >= 5 la consulta no devolvió ninguna fila, porque todos los grupos eran más pequeños que 5 y se suprimieron. Al principio me pareció raro, pero es lo que se esperaba con solo 5 clientes.

Lo que sigue siendo un riesgo es que los grupos pequeños se pueden identificar. Por ejemplo, el grupo de 46+ en la región 82 es una sola persona: alguien que conozca a un cliente de Mazatlán de esa edad lo reconocería. Además, aunque se cumpla k = 5, eso no garantiza que el conjunto sea anónimo, porque alguien podría cruzarlo con otras fuentes.

### Análisis de reidentificación

Los identificadores directos que eliminé son nombre, correo, teléfono y RFC. Los cuasi-identificadores que quedan son la edad (en rango), la región y, en la tabla analítica, la ciudad, el código postal completo y la fecha de alta. Las combinaciones que más bajan el anonimato son edad con región y ciudad, o edad con código postal exacto. Cuando un grupo tiene pocos registros se puede señalar a una persona concreta, a veces con un solo dato extra.

Generalizaría más la edad (rangos más amplios), el código postal (solo región) y la fecha de alta (solo mes o año). Suprimiría los grupos por debajo del umbral. No es correcto decir que el conjunto es 100 % anónimo: se redujo el riesgo, pero quedan cuasi-identificadores y no se puede descartar una reidentificación con otra fuente de datos.

### Reto

Quité la región, dejé solo dos rangos de edad (menos de 40 y 40+) y bajé el umbral a 3. El resultado fue que solo aparece el grupo "menos de 40" con 3 personas, y "40+" se suprime porque solo tiene 2. Con esto reduzco el riesgo de que alguien identifique a una persona cruzando edad y zona. Aun así, con solo 5 registros ningún umbral serio se cumple, el ejercicio sirve más para entender la lógica.

Las evidencias están en 04-anonimizacion.

## 5. Retención

Usé un periodo de 5 años como indica el ejercicio. La consulta devolvió 0 filas porque todos los clientes tienen fecha_alta del 17 de octubre de 2026, o sea que todavía no se vence ninguno. Para comprobar que la consulta funciona la probé con un periodo de 0 días y devolvió los 5 clientes. No ejecuté ningún DELETE.

En una empresa real el periodo dependería de la finalidad de los datos y de las obligaciones legales, fiscales o contractuales. Se conservaría lo necesario para cumplir con eso y para auditoría, y se podría eliminar lo que ya pasó su periodo y no tiene razón para seguir guardado.

Antes de borrar algo debería haber una aprobación por escrito del responsable de los datos (y de legal si aplica), y un respaldo reciente del que se haya comprobado que se puede restaurar. También habría que guardar evidencia de qué ids se borraron, cuándo, quién lo hizo y quién lo aprobó. Si se borra algo por error, se restauraría el respaldo en una base temporal y se volverían a insertar solo los registros afectados.

Las evidencias están en 05-retencion.

## 6. Conclusiones

Para soporte usaría enmascaramiento con una vista, porque necesitan identificar al cliente pero no ver todo. Para analítica usaría seudonimización con el mapa separado, porque necesitan analizar los datos sin saber quién es cada persona. Para publicar estadísticas usaría agregación y generalización con un mínimo de registros por grupo, porque no hace falta mostrar datos individuales.

Ninguna de estas técnicas sustituye al control de acceso porque si cualquiera puede leer la tabla original, todas se las puede saltar. En el laboratorio funcionaron porque las combiné con GRANT y REVOKE.

La verificación final (06-verificacion-final) muestra todos los accesos permitidos y los tres rechazados en una sola corrida.

## 7. Preguntas de reflexión

1. El enmascaramiento oculta cómo se ve un dato, pero el original sigue ahí. La seudonimización cambia el identificador por un token y guarda la relación aparte.
2. Porque con el mapa se puede volver a la persona, y los otros datos pueden seguir identificándola.
3. Porque edad, ciudad y código postal juntos pueden señalar a alguien, sobre todo en grupos pequeños.
4. Por sí solos no identifican, pero combinados con otros datos ayudan a reconocer a una persona.
5. Para que quien analiza los datos no pueda saber a quién pertenecen.
6. Mínimo privilegio y separación de funciones.
7. Porque controlas exactamente qué columnas se ven y la persona no toca los datos originales.
8. Proteger para visualización cambia lo que se muestra, pero si alguien accede a la tabla ve todo. Protegerlo contra acceso no autorizado impide el acceso con permisos.
9. Porque lo que no se guarda no se puede filtrar, y guardar datos que no se necesitan solo aumenta el riesgo.
10. Que si hay un incidente se expone más información de la necesaria, y se incumplen principios como la minimización y la finalidad de los datos.