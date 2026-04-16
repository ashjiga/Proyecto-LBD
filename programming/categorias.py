# CRUD de categorías llamando procedimientos y funciones (listar, insertar, actualizar y eliminar)
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

    lista = list(out.getvalue())

    conn.close()
    return render_template("categorias.html", categorias=lista)

@categorias_bp.route("/categorias/insertar", methods=["POST"])
def insertar_categoria():
    data = request.form

    conn = obtener_conexion()
    cursor = conn.cursor()

    nuevo_id = cursor.callfunc("FN_NUEVO_ID_CATEGORIA", int)

    cursor.callproc("ADD_CATEGORIA", [nuevo_id, data.get("nombre")])
    conn.commit()
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

@categorias_bp.route("/categorias/eliminar", methods=["POST"])
def eliminar_categoria():
    id_cat = int(request.form.get("id"))

    conn = obtener_conexion()
    cursor = conn.cursor()

    cursor.callproc("ELIMINAR_CAT", [id_cat])

    conn.commit()
    conn.close()
    return redirect("/categorias")