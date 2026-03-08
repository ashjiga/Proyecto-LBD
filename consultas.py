#Ejemplo de consulta
from conexion import obtener_conexion

conn = obtener_conexion()
print("Conexión exitosa")

with conn.cursor() as cursor:
    cursor.execute("SELECT * FROM Ventas")
    for fila in cursor:
        print(fila)

conn.close()