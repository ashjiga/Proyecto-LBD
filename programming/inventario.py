# inventario.py
from flask import Blueprint, render_template, request, redirect
from conexion import obtener_conexion

inventario_bp = Blueprint("inventario", __name__)

@inventario_bp.route("/inventario")
def inventario():
    conn = obtener_conexion()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT
            i.id_inventario,
            p.nombre,
            i.talla,
            i.stock_actual
        FROM Inventario i
        JOIN Productos p ON i.id_producto = p.id_producto
        ORDER BY p.nombre, i.talla
        """)

    lista = cursor.fetchall()
    cursor.close()
    conn.close()

    return render_template("inventario.html", inventario=lista)


@inventario_bp.route("/inventario/actualizar", methods=["POST"])
def actualizar_stock():
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