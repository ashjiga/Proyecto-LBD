import oracledb
from conexion import obtener_conexion

conn = obtener_conexion()
print("Conexión exitosa")

with conn.cursor() as cursor:
    out = conn.cursor()
    cursor.callproc("SP_SELECT_CLIENTES", [out])
    print("--- Lista de Clientes ---")
for fila in out:
        print(fila)

conn.close()
