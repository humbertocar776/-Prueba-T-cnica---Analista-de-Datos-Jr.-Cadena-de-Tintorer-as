### FASE 1: Cuestionario Teórico
**1. SQL / Normalización: Si tienes clientes duplicados porque el nombre se escribió con espacios al final o en minúsculas, ¿qué funciones SQL estándar aplicarías para consolidarlos y cómo garantizarías la integridad referencial en tu modelo estrella?**

Usaria TRIM() para eliminar espacios al inicio y al final de cada valor  y LOWER() para poner el nombre en minusculas , despues haria  una consulta donde agruparia los registros por nombres y otros atributos que tenga el registros para asi identificar cuales verdaderamente son duplicados ya que puede existir dos personas con el mismo nombre, por eso debemos comparar con demas campos , despues de eliminar los duplicados asignaria un id_unico para cada registro

**2. SQL analítico: ¿Cuál es la diferencia técnica entre usar un GROUP BY tradicional y utilizar una función de ventana como SUM(monto) OVER(PARTITION BY sucursal)?**

La diferencia es que GROUP BY() realiza la operacion a la agrupacion , es decir agrupa y despues aplica la operacion a las filas que continen y muestra ese resultado mientras que SUM(monto) OVER(PARTITION BY sucursal) mantiene la estructura de la tabla pero agregando el resultado que daria la opeacion con el agrupamiento es este caso por la sucursal de fila 

**3.Python / Pipelines: Si tu script de pandas recibe un archivo donde una columna numérica viene con texto basura ("N/A", "NULL"), ¿qué métodos utilizarías para forzar la conversión numérica sin que el script colapse en producción?**

Utilizaria el parametro errors = "coerce" en este caso como se nos dice que es numerica seria pd.to_numeric(serie_numerica,errors = "coerce"), aunque si esta datos de fechas de igual manera puedo una errors="coerce" ya que pd.to_datetime() acepta el mismo argumento y este lo que hace es cuando no puede tranformar un dato por ejemplo "N/A" es str o string en vez de dar error deja pasar estos datos convirtiendolos en NAN 

**4. DAX / Power BI: ¿Por qué una métrica de ingresos debe escribirse como una Medida DAX con SUM() o SUMX() en lugar de crear una columna calculada para cada operación matemática?**
Porque al crear un columna calculada el reporte ocupa mas espacio ademas se pierde la flexibilidad de un indicador es decir si yo hago un indicador que compara las ventas de un vendedor este mes con respecto al mes anterior podria hacer diferencia ventas = sumx(fctventas,fctventas[cantidad]*fctventas[precio]) - calculate(sumx(fctventas,fctventas[cantidad]*fctventas[precio]),dateadd(dimcalendario["fecha"] , -1 , year)), y por ejemplo si yo hago una columna donde para cada empleado yo hago una columna calculada con sus ventas , esta registrara las ventas de todas fechas y no considerara el contexto de filtro es por eso que es mejor, ya que es mas dinamico y optimo una medida que solo se ejecuta cuando se usa.

**5. Gobierno / Seguridad Pro: Un director te pide compartir el reporte de ingresos con un socio externo enviándole el enlace de "Publicar en la web" (Publish to Web) para ahorrar licencias de Power BI Pro. ¿Qué le respondes?**
Estaria dudoso ya que es un director , consultaria con otros directos o personal para saber si es lo correcto.

 **1.	Seguridad (RLS): Explica detalladamente cómo configurarías la seguridad a nivel de fila para que el Gerente de la sucursal "Metropolitana" solo pueda ver los datos de su local usando USERPRINCIPALNAME().**
Lo primero seria hacer mi dimension Sucursal donde para cada sucursal le asignaria el correo del gerente de la sucursal y asi para cada correo con el respectivo sucursal que pueden ver, esta dimension la relaciono con la tabla de hechos para que asi el gerente solo pueda ver la informacion de la sucursal ya que filtra , despues en Manage security roles asigno la regla para el filtrado donde seria dimsuculsal["Correo"] = USERPRINCIPALNAME()