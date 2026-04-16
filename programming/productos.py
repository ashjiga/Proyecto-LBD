# productos.py
from flask import Blueprint, render_template, request, redirect
from conexion import obtener_conexion

productos_bp = Blueprint("productos", __name__)

# Mostrar productos y categorías
@productos_bp.route("/productos")
def productos():
    conn = obtener_conexion()
    cursor = conn.cursor()

    # Lista de productos
    cursor.execute("""
        SELECT
            p.id_producto,
            p.nombre,
            p.descripcion,
            c.nombre_categoria,
            p.precio_venta,
            p.id_categoria
        FROM Productos p
        JOIN Categorias c ON p.id_categoria = c.id_categoria
        ORDER BY p.id_producto
        """)
    lista = cursor.fetchall()

    cursor.execute("SELECT id_categoria, nombre_categoria FROM Categorias ORDER BY nombre_categoria")
    categorias = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template("productos.html", productos=lista, categorias=categorias)

# Agregar producto
@productos_bp.route("/productos/agregar", methods=["POST"])
def agregar_producto():
    data = request.form

    conn = obtener_conexion()
    cursor = conn.cursor()

    cursor.execute("SELECT NVL(MAX(id_producto), 0) + 1 FROM Productos")
    nuevo_id = cursor.fetchone()[0]

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

# Actualizar producto
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

# Eliminar producto
@productos_bp.route("/productos/eliminar", methods=["POST"])
def eliminar_producto():
    data = request.form

    conn = obtener_conexion()
    cursor = conn.cursor()

    cursor.callproc("SP_BORRAR_PRODUCTO", [int(data.get("id"))])

    conn.commit()
    cursor.close()
    conn.close()
    return redirect("/productos")