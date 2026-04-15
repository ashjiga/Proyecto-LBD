from flask import Blueprint, render_template, request, redirect
import oracledb
from conexion import obtener_conexion

categorias_bp = Blueprint("categorias", __name__)


@categorias_bp.route("/categorias")
def categorias():
    conn = obtener_conexion()
    cursor = conn.cursor()

    out = cursor.var(oracledb.CURSOR)
    cursor.callproc("LISTAR_CATEGORIAS", [out])

    result = out.getvalue()
    lista = []
    for fila in result:
        lista.append(fila)

    conn.close()
    return render_template("categorias.html", categorias=lista)


@categorias_bp.route("/categorias/insertar", methods=["POST"])
def insertar_categoria():
    data = request.form

    id_cat = data.get("id")
    if not id_cat:
        return "Error: debe ingresar ID"

    conn = obtener_conexion()
    cursor = conn.cursor()

    try:
        cursor.callproc("ADD_CATEGORIA", [
            int(id_cat),
            data.get("nombre")
        ])
        conn.commit()
    except oracledb.IntegrityError:
        conn.close()
        return "Error: el ID ya existe"

    conn.close()
    return redirect("/categorias")


@categorias_bp.route("/categorias/actualizar", methods=["POST"])
def actualizar_categoria():
    data = request.form

    conn = obtener_conexion()
    cursor = conn.cursor()

    cursor.callproc("UPDATE_CATEGORIA", [
        int(data.get("id")),
        data.get("nombre")
    ])

    conn.commit()
    conn.close()
    return redirect("/categorias")


@categorias_bp.route("/categorias/eliminar/<int:id>")
def eliminar_categoria(id):
    conn = obtener_conexion()
    cursor = conn.cursor()

    cursor.callproc("ELIMINAR_CAT", [id])

    conn.commit()
    conn.close()
    return redirect("/categorias")