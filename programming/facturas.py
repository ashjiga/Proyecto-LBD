from flask import Blueprint, render_template, request, redirect
from conexion import obtener_conexion

facturas_bp = Blueprint("facturas", __name__)


@facturas_bp.route("/facturas")
def facturas():
    conn = obtener_conexion()
    cursor = conn.cursor()

    cursor.execute("""
    SELECT DISTINCT
        f.id_factura,
        f.numero_factura,
        nombre_cliente(v.id_cliente),
        f.fecha_emision,
        f.total_factura,
        f.estado
    FROM Facturas f
    JOIN Ventas v ON f.id_venta = v.id_venta
    JOIN Detalle_Facturas df ON df.id_factura = f.id_factura
    ORDER BY f.numero_factura
    """)

    lista = cursor.fetchall()
    conn.close()

    return render_template("facturas.html", facturas=lista)

@facturas_bp.route("/facturas/actualizar", methods=["POST"])
def actualizar_factura():
    data = request.form

    conn = obtener_conexion()
    cursor = conn.cursor()

    cursor.callproc("SP_MODIFICAR_FACTURA", [
        int(data.get("id")),
        data.get("estado")
    ])

    conn.commit()
    cursor.close()
    conn.close()
    return redirect("/facturas")