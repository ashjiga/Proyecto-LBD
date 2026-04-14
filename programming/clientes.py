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

    result = out.getvalue()

    lista = []
    for fila in result:
        lista.append(fila)

    conn.close()

    return render_template("clientes.html", clientes=lista)


@clientes_bp.route("/insertar", methods=["POST"])
def insertar():
    data = request.form

    id_cliente = data.get("id")

    if not id_cliente:
        return "Error: debe ingresar ID"

    conn = obtener_conexion()
    cursor = conn.cursor()

    try:
        cursor.callproc("INSERTAR_CLIENTE", [
            int(id_cliente),
            data.get("nombre"),
            data.get("apellido"),
            data.get("telefono"),
            data.get("email")
        ])
        conn.commit()

    except oracledb.IntegrityError:
        conn.close()
        return "Error: el ID ya existe, use otro"

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


@clientes_bp.route("/eliminar/<int:id>")
def eliminar(id):
    conn = obtener_conexion()
    cursor = conn.cursor()

    cursor.callproc("BORRAR_CLIENTE", [id])

    conn.commit()
    conn.close()

    return redirect("/clientes")