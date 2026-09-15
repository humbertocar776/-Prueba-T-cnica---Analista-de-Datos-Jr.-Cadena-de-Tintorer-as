"""
Módulo 2: Pipeline de Datos en Python (Estilo Producción) Desarrolla
un script modular en Python (etl_pipeline.py) estructurado en funciones (extract(),
transform(), load()). No aceptaremos scripts lineales de Jupyter Notebook.)
"""

""" 1.	Transformación Numérica: Utiliza pandas para limpiar las columnas cantidad_prendas, precio_unitario y descuento.
Obliga su conversión a formato numérico gestionando los errores (convirtiendo los strings corruptos a nulos) y rellena los nulos con ceros (0)."""

import pandas as pd

Ruta_Ingresada = "Resultados_sin_repetidos.csv" # Use la consulta de SQL sin registros repetidos para este
Ruta_guardado = "Dataset_Ventas_Limpios.csv"

# Columnas numéricas que deben limpiarse.
Columnas_numericas= ["cantidad_prendas", "precio_unitario", "descuento"]


def extract(Ruta_Ingresada: str = Ruta_Ingresada) -> pd.DataFrame:
    """
    Extrae los datos crudos desde el archivo CSV de mi consulta SQL.
    """
    df = pd.read_csv(Ruta_Ingresada)
    return df


def cambiar_serie_a_tipo_numerica(series: pd.Series) -> pd.Series:
    
    #- Quitamos símbolos comunes que aparecen en los datos ($, %, espacios,"MXN") 
    cleaned = (
        series.astype(str)
        .str.strip()
        .str.replace("$", "", regex=False)
        .str.replace("%", "", regex=False)
        .str.replace(",", "", regex=False)
        .str.replace("MXN" , "",regex = False)
        .str.strip()
    )
    numeric = pd.to_numeric(cleaned, errors="coerce") #con esto valores como Null , N/A que igual aparecen en automatico los convierte en NaN
    return numeric


def transform(df: pd.DataFrame) -> pd.DataFrame:
    
    #Transformamos nuestro dataframe aplicando nuestra funcion cambiar_serie_a_tipo_numerica a cada columna numerica para posteiormente rellanarlo con 0.
    #para esto usamo fillna
    # 1. Transformación numérica
    for col in Columnas_numericas:
        df[col] = cambiar_serie_a_tipo_numerica(df[col])
        df[col] = df[col].fillna(0)

    # 2.Cálculo Derivado: Crea una nueva columna llamada Precio_Final_Descuento. Para calcularlo, aplica la fórmula: Precio Unitario * (1 - (Descuento / 100)).
    df["Precio_Final_Descuento"] = df["precio_unitario"] * (1 - (df["descuento"] / 100)) 

    return df


def load(df: pd.DataFrame, output_path: str = Ruta_guardado) -> None:
    #Exportamos la tabla limpia en csv , con en encoding "utf-8_sig"
    df.to_csv(output_path, index=False, encoding="utf-8-sig")


def main():
    df_sucio = extract()
    df_limpio = transform(df_sucio)
    load(df_limpio)
    print("Pipeline ejecutado correctamente.")


if __name__ == "__main__":
    main()
