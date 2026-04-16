# Consulta y muestra el detalle de facturas usando un procedimiento almacenado
from flask import Blueprint, render_template
from conexion import obtener_conexion
import oracledb

detalle_facturas_bp = Blueprint("detalle_facturas", __name__)

@detalle_facturas_bp.route("/detalle_facturas")
def detalle_facturas():

    conn = obtener_conexion()
    cursor = conn.cursor()

    out_cursor = cursor.var(oracledb.CURSOR)

    cursor.callproc("SP_DETALLE_FACTURAS_COMPLETO", [out_cursor])

    detalles = out_cursor.getvalue().fetchall()

    cursor.close()
    conn.close()

    return render_template("detalle_facturas.html", detalles=detalles)