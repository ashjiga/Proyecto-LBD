# Consulta y muestra el detalle de ventas usando un procedimiento almacenado
from flask import Blueprint, render_template
from conexion import obtener_conexion
import oracledb

detalle_ventas_bp = Blueprint("detalle_ventas", __name__)

@detalle_ventas_bp.route("/detalle_ventas")
def detalle_ventas():

    conn = obtener_conexion()
    cursor = conn.cursor()

    out_cursor = cursor.var(oracledb.CURSOR)

    cursor.callproc("SP_LISTAR_VENTAS", [out_cursor])

    ventas = out_cursor.getvalue().fetchall()

    cursor.close()
    conn.close()

    return render_template("detalle_ventas.html", ventas=ventas)