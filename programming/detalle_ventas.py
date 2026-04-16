from flask import Blueprint, render_template
from conexion import obtener_conexion

detalle_ventas_bp = Blueprint("detalle_ventas", __name__)

@detalle_ventas_bp.route("/detalle_ventas")
def detalle_ventas():

    conn = obtener_conexion()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT 
            v.id_venta,
            nombre_cliente(v.id_cliente),
            v.fecha,
            v.total
        FROM Ventas v
        ORDER BY v.id_venta DESC
        """)

    ventas = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template("detalle_ventas.html", ventas=ventas)