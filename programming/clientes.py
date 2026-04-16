# CRUD de clientes llamando procedimientos y funciones (listar, insertar, actualizar y eliminar)
from flask import Blueprint, render_template, request, redirect
import oracledb
from conexion import obtener_conexion

clientes_bp = Blueprint("clientes", __name__)

@clientes_bp.route("/clientes")
def clientes():
    conn = obtener_conexion()
    cursor = conn.cursor()

    out = cursor.var(oracledb.CURSOR)
    cursor.callproc("GET_CLIENTES", [out])

    lista = list(out.getvalue())

    conn.close()
    return render_template("clientes.html", clientes=lista)

@clientes_bp.route("/insertar", methods=["POST"])
def insertar():
    data = request.form

    conn = obtener_conexion()
    cursor = conn.cursor()

    nuevo_id = cursor.callfunc("FN_NUEVO_ID_CLIENTE", int)

    cursor.callproc("INSERTAR_CLIENTE", [
        nuevo_id,
        data.get("nombre"),
        data.get("apellido"),
        data.get("telefono"),
        data.get("email")
    ])

    conn.commit()
    conn.close()
    return redirect("/clientes")

@clientes_bp.route("/actualizar", methods=["POST"])
def actualizar():
    data = request.form

    conn = obtener_conexion()
    cursor = conn.cursor()

    cursor.callproc("MODIFICA_CLIENTE", [
        int(data.get("id")),
        data.get("nombre"),
        data.get("apellido"),
        data.get("telefono"),
        data.get("email")
    ])

    conn.commit()
    conn.close()
    return redirect("/clientes")

@clientes_bp.route("/eliminar", methods=["POST"])
def eliminar():
    id_cliente = int(request.form.get("id"))

    conn = obtener_conexion()
    cursor = conn.cursor()

    cursor.callproc("BORRAR_CLIENTE", [id_cliente])

    conn.commit()
    conn.close()
    return redirect("/clientes")