from flask import Blueprint, render_template
from conexion import obtener_conexion

historial_ventas_bp = Blueprint("historial_ventas", __name__)

# Mostrar historial de ventas
@historial_ventas_bp.route("/historial_ventas")
def historial():

    conn = obtener_conexion()
    cursor = conn.cursor()

    # Consulta con agregaciones (total, cantidad y productos vendidos)
    cursor.execute("""
    SELECT
        nombre_cliente(v.id_cliente),
        v.fecha,
        f.total_factura,
        f.numero_factura,
        SUM(dv.cantidad),
        LISTAGG(p.nombre, ', ') WITHIN GROUP (ORDER BY p.nombre)
        FROM Ventas v
        JOIN Facturas f ON f.id_venta = v.id_venta
        JOIN Detalle_Ventas dv ON dv.id_venta = v.id_venta
        JOIN Inventario i ON dv.id_inventario = i.id_inventario
        JOIN Productos p ON i.id_producto = p.id_producto
        GROUP BY 
        nombre_cliente(v.id_cliente),
        v.fecha,
        f.total_factura,
        f.numero_factura,
        v.id_venta
    ORDER BY v.id_venta DESC
    """)

    lista = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template("historial_ventas.html", historial=lista)