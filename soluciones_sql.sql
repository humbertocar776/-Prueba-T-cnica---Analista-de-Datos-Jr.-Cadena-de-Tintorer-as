/* 
1.	Escribe una consulta SQL (usando Common Table Expressions o CTEs) que aplique la función ROW_NUMBER()
para identificar y eliminar los registros duplicados del dataset, conservando únicamente la operación más reciente 
por transacción. 
*/

WITH ventas_normalizadas AS (
    SELECT
        raw_id,                                             
        TRIM(UPPER(fecha_recepcion))	As fecha_recepcion_norma,
        TRIM(UPPER(cliente_nombre))     As cliente_nombre_norma,
        TRIM(UPPER(cliente_email))      As cliente_email_norma,         -- Normalizamos los datos de las columnas con datos strings
        TRIM(UPPER(sucursal))    	AS sucursal_norma,              --Quitamos espacion en blando de al final y principio
        TRIM(UPPER(canal_venta)) 	AS canal_venta_norma,           --para que elemento iguales , se agrupen como iguales y no por
        TRIM(UPPER(proceso))     	AS proceso_norma,               -- tener caracter distintos se agrupen diferente, porque asi no
        TRIM(UPPER(categoria))   	AS categoria_norma,             -- podriamos eliminarlos
        TRIM(UPPER(tipo_prenda)) 	AS tipo_prenda_norma,
        cantidad_prendas,
        precio_unitario,
        descuento,
        id_cajero
    FROM Ventas_Repetidas
),

ventas_duplicadas AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY
                cliente_nombre_norma,           --le asignamos un #registro a cada registro diferente, los repetidos son los unicos
                cliente_email_norma,            --que tendran #registro de 1,2 o mas  , ya que tenemos registros que se agruparon,
                sucursal_norma,                 -- y por eso les puso un #registro disntito a 1, ordenamos por raw_id ya que vemos que este 
                proceso_norma,                  -- es creciente entonces el registro mas proximo fue el que tiene un id_mayor
                categoria_norma,                --entonces de los registros repetidos nos quedaremos con el que tiene el mayor raw_id
                tipo_prenda_norma,              --por eso raw_id desc
                cantidad_prendas,
                fecha_recepcion_norma
            ORDER BY raw_id DESC          
        ) AS #registros
    FROM ventas_normalizadas
)

SELECT
    raw_id,
    fecha_recepcion_norma	AS fecha_recepcion,
    cliente_nombre_norma	AS cliente_nombre,
    cliente_email_norma		AS cliente_email,
    sucursal_norma    		AS sucursal,              --Aqui obtenemos la consulta final sin registros repetidos para esto filtramos    
    canal_venta_norma 		AS canal_venta,           -- solo a los que tienen un #registros=1 , no traemos a esa columna al final de la consulta.
    proceso_norma     		AS proceso,
    categoria_norma  		 AS categoria,
    tipo_prenda_norma		 AS tipo_prenda,
    cantidad_prendas,
    precio_unitario,
    descuento,
    id_cajero
FROM ventas_duplicadas
WHERE #registros= 1;  

/* 
2.	Escribe una sentencia SQL para crear un ID único compuesto concatenando la sucursal y el raw_id, 
manejando los valores nulos para evitar IDs falsos.
*/

SELECT 
    COALESCE(NULLIF(TRIM(UPPER(sucursal)), ''), 'SIN_SUCURSAL')
        + '-' +                                                    -- verificamos si sucursal es nulo tanto como texto ("") o como valor NULL 
    COALESCE(CAST(raw_id AS VARCHAR), 'SIN_ID') AS id_operacion    -- le pondremos "SIN_SUCURSAL" y lo uniremos con el raw_id convertido a string o varchar
FROM Ventas_Repetidas;                                             -- asi no causara error y la combinacion se hara



/*
3.	Diseña el DDL (Data Definition Language) para crear un esquema en estrella normalizado que contenga:
dim_cliente, dim_servicio, dim_fecha y fact_operaciones. 
*/

CREATE TABLE dim_cliente (
    cliente_id      INT IDENTITY(1,1) PRIMARY KEY,    -- Ponemos las principales columnas que puede tener una dim_cliente
    cliente_nombre  VARCHAR(150) NOT NULL,            -- Ponemos el identificador de cada registro
    cliente_email   VARCHAR(150),
    CONSTRAINT uq_cliente UNIQUE (cliente_nombre, cliente_email) -- buscamos que no haya registros que repitan nombre y correo
);
 

CREATE TABLE dim_servicio (
    servicio_id     INT IDENTITY(1,1) PRIMARY KEY,        --ponemos prinpales columnas de dimservicio
    canal_venta     VARCHAR(30)  NOT NULL,   
    proceso         VARCHAR(50)  NOT NULL,   
    categoria       VARCHAR(50)  NOT NULL,   
    tipo_prenda     VARCHAR(100),
    CONSTRAINT uq_servicio UNIQUE (canal_venta, proceso, categoria, tipo_prenda) -- igual que no tenga registros que compartan todos los apartados iguales
);
 

CREATE TABLE dim_fecha (
    fecha_id        INT PRIMARY KEY,        
    fecha           DATE NOT NULL UNIQUE,
    anio            SMALLINT NOT NULL,
    mes             SMALLINT NOT NULL,
    nombre_mes      VARCHAR(15) NOT NULL,
    dia             SMALLINT NOT NULL,
    trimestre       SMALLINT NOT NULL,
    dia_semana      SMALLINT NOT NULL,       
    nombre_dia      VARCHAR(15) NOT NULL,
);

CREATE TABLE fact_operaciones (
    operacion_id      INT IDENTITY(1,1) PRIMARY KEY, --generamos un id_automatico
    raw_id            INT NOT NULL,               
    id_operacion      VARCHAR(100) NOT NULL,       
    cliente_id        INT NOT NULL REFERENCES dim_cliente(cliente_id), -- buscamos que no se ingreses cliente_id que no existen
    servicio_id       INT NOT NULL REFERENCES dim_servicio(servicio_id), --buscamos que no se ingreses servicio_id que no existen
    fecha_id          INT NOT NULL REFERENCES dim_fecha(fecha_id),       -- buscamos que no se ingreses fecha_id que no existen
    sucursal          VARCHAR(50)  NOT NULL,       
    id_cajero         INT,                         
    cantidad_prendas  INT NOT NULL,
    precio_unitario   NUMERIC(10,2) NOT NULL,
    descuento_pct     NUMERIC(5,4) NOT NULL DEFAULT 0,
    CONSTRAINT uq_raw_id UNIQUE (raw_id),                --que no se repitan ids , aqui no ponemos que no se repitan todos los campos pues
    CONSTRAINT uq_id_operacion_fact UNIQUE (id_operacion) -- un mismo cliente puede hacer dos compras iguales y no es algo incorrecto
);