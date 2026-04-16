from flask import Blueprint, render_template, request, redirect
from conexion import obtener_conexion

facturas_bp = Blueprint("facturas", __name__)

# Mostrar facturas
@facturas_bp.route("/facturas")
def facturas():

    conn = obtener_conexion()
    cursor = conn.cursor()

    # Consulta de facturas con datos del cliente
    cursor.execute("""
        SELECT 
            f.id_factura,
            f.numero_factura,
            nombre_cliente(v.id_cliente),
            f.fecha_emision,
            f.total_factura,
            f.estado
        FROM Facturas f
        JOIN Ventas v ON f.id_venta = v.id_venta
        ORDER BY f.id_factura DESC
        """)

    lista = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template("facturas.html", facturas=lista)


# Actualizar estado de la factura
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

# Ir al detalle de facturas
@facturas_bp.route("/facturas/ver_detalle")
def ver_detalle_facturas():
    return redirect("/detalle_facturas")