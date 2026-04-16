# Consulta y muestra el historial de ventas usando un procedimiento almacenado
from flask import Blueprint, render_template
import oracledb
from conexion import obtener_conexion

historial_ventas_bp = Blueprint("historial_ventas", __name__)

@historial_ventas_bp.route("/historial_ventas")
def historial():

    conn = obtener_conexion()
    cursor = conn.cursor()

    out = cursor.var(oracledb.CURSOR)
    cursor.callproc("SP_HISTORIAL_VENTAS", [out])

    lista = list(out.getvalue())

    cursor.close()
    conn.close()

    return render_template("historial_ventas.html", historial=lista)