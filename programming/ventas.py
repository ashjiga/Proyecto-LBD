from flask import Blueprint, render_template, request, redirect
from conexion import obtener_conexion

ventas_bp = Blueprint("ventas", __name__)

# Vista de ventas (clientes e inventario)
@ventas_bp.route("/ventas")
def vista_ventas():

    conn = obtener_conexion()
    cursor = conn.cursor()

    # Clientes disponibles
    cursor.execute("""
        SELECT id_cliente, nombre, apellido
        FROM Clientes
    """)
    clientes = cursor.fetchall()

    # Inventario disponible para venta
    cursor.execute("""
        SELECT 
            i.id_inventario,
            p.nombre,
            p.precio_venta,
            i.stock_actual
        FROM Inventario i
        JOIN Productos p ON p.id_producto = i.id_producto
    """)
    inventario = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template("ventas.html",
                           clientes=clientes,
                           inventario=inventario)

# Crear una venta completa
@ventas_bp.route("/ventas/crear", methods=["POST"])
def crear_venta():

    id_cliente = request.form.get("id_cliente")
    id_inventario = request.form.get("id_inventario")
    cantidad = request.form.get("cantidad")

    if not id_cliente or not id_inventario or not cantidad:
        return redirect("/ventas")

    id_cliente = int(id_cliente)
    id_inventario = int(id_inventario)
    cantidad = int(cantidad)

    conn = obtener_conexion()
    cursor = conn.cursor()

    try:
        cursor.callproc("pkg_ventas.crear_venta", [id_cliente])

        cursor.execute("""
            SELECT id_venta
            FROM Ventas
            WHERE id_cliente = :id
            ORDER BY id_venta DESC
            FETCH FIRST 1 ROWS ONLY
        """, id=id_cliente)

        id_venta = cursor.fetchone()[0]

        cursor.execute("""
            SELECT p.precio_venta
            FROM Inventario i
            JOIN Productos p ON p.id_producto = i.id_producto
            WHERE i.id_inventario = :inv
        """, inv=id_inventario)

        precio = cursor.fetchone()[0]

        cursor.callproc("pkg_ventas.agregar_detalle", [
            id_venta,
            id_inventario,
            cantidad,
            float(precio)
        ])

        cursor.execute("""
            INSERT INTO Facturas (
                id_factura,
                id_venta,
                numero_factura,
                fecha_emision,
                subtotal,
                impuesto,
                total_factura,
                estado
            )
            VALUES (
                seq_historial_ventas.NEXTVAL,
                :id_venta,
                'FAC-' || :id_venta,
                SYSDATE,
                fn_total_venta(:id_venta),
                0,
                fn_total_venta(:id_venta),
                'Pendiente'
            )
        """, id_venta=id_venta)

        cursor.execute("""
            INSERT INTO Detalle_Facturas (
                id_detalle_fac,
                id_factura,
                id_inventario,
                cantidad,
                subtotal_linea
            )
            SELECT 
                seq_detalle_factura.NEXTVAL,
                f.id_factura,
                dv.id_inventario,
                dv.cantidad,
                dv.cantidad * dv.precio_unitario
            FROM Facturas f
            JOIN Ventas v ON f.id_venta = v.id_venta
            JOIN Detalle_Ventas dv ON dv.id_venta = v.id_venta
            WHERE f.id_venta = :id_venta
        """, id_venta=id_venta)

        conn.commit()

    except Exception as e:
        conn.rollback()
        print("ERROR:", e)
        raise

    finally:
        cursor.close()
        conn.close()

    return redirect("/detalle_ventas?ok=1")