from flask import Blueprint, render_template, request, redirect
import oracledb
from conexion import obtener_conexion

productos_bp = Blueprint("productos", __name__)

@productos_bp.route("/productos")
def productos():
    conn = obtener_conexion()
    cursor = conn.cursor()

    out_prod = cursor.var(oracledb.CURSOR)
    cursor.callproc("SP_LISTAR_PRODUCTOS_FULL", [out_prod])
    lista = list(out_prod.getvalue())

    out_cat = cursor.var(oracledb.CURSOR)
    cursor.callproc("SP_LISTAR_CATEGORIAS", [out_cat])
    categorias = list(out_cat.getvalue())

    cursor.close()
    conn.close()

    return render_template("productos.html",
                           productos=lista,
                           categorias=categorias)


@productos_bp.route("/productos/agregar", methods=["POST"])
def agregar_producto():
    data = request.form

    conn = obtener_conexion()
    cursor = conn.cursor()

    nuevo_id = cursor.callfunc("FN_NUEVO_ID_PRODUCTO", int)

    cursor.callproc("SP_NUEVO_PRODUCTO", [
        nuevo_id,
        int(data.get("id_categoria")),
        data.get("nombre"),
        data.get("descripcion"),
        float(data.get("precio"))
    ])

    conn.commit()
    cursor.close()
    conn.close()

    return redirect("/productos")


@productos_bp.route("/productos/actualizar", methods=["POST"])
def actualizar_producto():
    data = request.form

    conn = obtener_conexion()
    cursor = conn.cursor()

    cursor.callproc("SP_EDITAR_PRODUCTO", [
        int(data.get("id")),
        int(data.get("id_categoria")),
        data.get("nombre"),
        data.get("descripcion"),
        float(data.get("precio"))
    ])

    conn.commit()
    cursor.close()
    conn.close()

    return redirect("/productos")


@productos_bp.route("/productos/eliminar", methods=["POST"])
def eliminar_producto():
    data = request.form

    conn = obtener_conexion()
    cursor = conn.cursor()

    cursor.callproc("SP_BORRAR_PRODUCTO", [
        int(data.get("id"))
    ])

    conn.commit()
    cursor.close()
    conn.close()

    return redirect("/productos")