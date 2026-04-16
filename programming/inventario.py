# Consulta y actualización del inventario llamando procedimientos almacenados
from flask import Blueprint, render_template, request, redirect
import oracledb
from conexion import obtener_conexion

inventario_bp = Blueprint("inventario", __name__)

@inventario_bp.route("/inventario")
def inventario():
    conn = obtener_conexion()
    cursor = conn.cursor()

    out = cursor.var(oracledb.CURSOR)
    cursor.callproc("SP_LISTAR_INVENTARIO", [out])

    lista = list(out.getvalue())

    cursor.close()
    conn.close()

    return render_template("inventario.html", inventario=lista)


@inventario_bp.route("/inventario/actualizar", methods=["POST"])
def actualizar_inventario():
    data = request.form

    conn = obtener_conexion()
    cursor = conn.cursor()

    cursor.callproc("SP_MODIFICAR_INVENTARIO", [
        int(data.get("id")),
        int(data.get("stock"))
    ])

    conn.commit()
    cursor.close()
    conn.close()

    return redirect("/inventario")