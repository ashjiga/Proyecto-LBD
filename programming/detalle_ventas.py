from flask import Blueprint, render_template
from conexion import obtener_conexion

detalle_ventas_bp = Blueprint("detalle_ventas", __name__)


@detalle_ventas_bp.route("/detalle_ventas")
def detalle_ventas():
    conn = obtener_conexion()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT 
            dv.id_venta,
            p.nombre,
            i.talla,
            dv.cantidad,
            dv.precio_unitario
        FROM Detalle_Ventas dv
        JOIN Inventario i ON dv.id_inventario = i.id_inventario
        JOIN Productos p ON i.id_producto = p.id_producto
        ORDER BY dv.id_venta
        """)

    lista = cursor.fetchall()
    conn.close()

    return render_template("detalle_ventas.html", detalles=lista)