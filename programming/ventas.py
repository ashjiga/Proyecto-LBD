# Gestión de ventas usando procedimientos, funciones y paquetes para consultar datos y crear ventas con su detalle y factura
from flask import Blueprint, render_template, request, redirect
from conexion import obtener_conexion
import oracledb

ventas_bp = Blueprint("ventas", __name__)

@ventas_bp.route("/ventas")
def vista_ventas():

    conn = obtener_conexion()
    cursor = conn.cursor()

    try:
        clientes_cursor = cursor.connection.cursor()
        cursor.callproc("GET_CLIENTES", [clientes_cursor])
        clientes = clientes_cursor.fetchall()
        clientes_cursor.close()

        inventario_cursor = cursor.connection.cursor()
        cursor.callproc("SP_LISTAR_INVENTARIO", [inventario_cursor])
        inventario = inventario_cursor.fetchall()
        inventario_cursor.close()

    except Exception as e:
        print("ERROR:", e)
        clientes = []
        inventario = []

    finally:
        cursor.close()
        conn.close()

    return render_template(
        "ventas.html",
        clientes=clientes,
        inventario=inventario
    )

@ventas_bp.route("/ventas/crear", methods=["POST"])
def crear_venta():

    id_cliente = int(request.form.get("id_cliente"))
    id_inventario = int(request.form.get("id_inventario"))
    cantidad = int(request.form.get("cantidad"))

    conn = obtener_conexion()
    cursor = conn.cursor()

    try:
        id_venta = cursor.var(int)

        cursor.callproc("PKG_VENTAS.CREAR_VENTA", [
            id_cliente,
            id_venta
        ])

        id_venta = id_venta.getvalue()

        precio = cursor.callfunc(
            "precio_por_inventario",
            float,
            [id_inventario]
        )

        cursor.callproc("PKG_VENTAS.AGREGAR_DETALLE", [
            id_venta,
            id_inventario,
            cantidad,
            precio
        ])

        cursor.callproc("SP_CREAR_FACTURA", [
            id_venta
        ])

        conn.commit()

    except Exception as e:
        conn.rollback()
        print("ERROR:", e)
        return redirect("/ventas?error=1")

    finally:
        cursor.close()
        conn.close()

    return redirect("/detalle_ventas?ok=1")