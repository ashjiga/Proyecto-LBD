# Consulta y actualización de facturas llamando procedimientos almacenados
from flask import Blueprint, render_template, request, redirect
import oracledb
from conexion import obtener_conexion

facturas_bp = Blueprint("facturas", __name__)

@facturas_bp.route("/facturas")
def facturas():

    conn = obtener_conexion()
    cursor = conn.cursor()

    try:
        out = cursor.var(oracledb.CURSOR)

        cursor.callproc("SP_LISTAR_FACTURAS", [out])

        result_cursor = out.getvalue()
        lista = result_cursor.fetchall()

    except Exception as e:
        print("ERROR LISTANDO FACTURAS:", e)
        lista = []

    finally:
        cursor.close()
        conn.close()

    return render_template("facturas.html", facturas=lista)


@facturas_bp.route("/facturas/actualizar/<int:id>", methods=["POST"])
def actualizar_factura(id):

    estado = request.form.get("estado")
    impuesto = request.form.get("impuesto")

    try:
        impuesto = float(impuesto)
    except:
        impuesto = 0

    conn = obtener_conexion()
    cursor = conn.cursor()

    try:
        cursor.callproc("SP_ACTUALIZAR_FACTURA", [
            id,
            estado,
            impuesto
        ])

        conn.commit()

    except Exception as e:
        print("ERROR ACTUALIZANDO FACTURA:", e)

    finally:
        cursor.close()
        conn.close()

    return redirect("/facturas")