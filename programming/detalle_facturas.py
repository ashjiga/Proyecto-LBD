from flask import Blueprint, render_template
from conexion import obtener_conexion

detalle_facturas_bp = Blueprint("detalle_facturas", __name__)

@detalle_facturas_bp.route("/detalle_facturas")
def detalle_facturas():
    conn = obtener_conexion()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT 
            f.numero_factura,
            f.estado,
            p.nombre,
            i.talla,
            df.cantidad,
            df.subtotal_linea
        FROM Detalle_Facturas df
        JOIN Facturas f      ON df.id_factura   = f.id_factura
        JOIN Inventario i    ON df.id_inventario = i.id_inventario
        JOIN Productos p     ON i.id_producto    = p.id_producto
        ORDER BY f.id_factura, df.id_detalle_fac
        """)

    lista = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template("detalle_facturas.html", detalles=lista)