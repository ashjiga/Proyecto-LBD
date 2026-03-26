--Total de una venta
CREATE OR REPLACE FUNCTION fn_total_venta(p_id_venta NUMBER)
RETURN NUMBER IS
    v_total NUMBER;
BEGIN
    SELECT SUM(cantidad * precio_unitario)
    INTO v_total
    FROM Detalle_Ventas
    WHERE id_venta = p_id_venta;

    RETURN NVL(v_total,0);
END;
/

--Stock disponible por producto y talla
CREATE OR REPLACE FUNCTION stock_disponible(
    p_id_producto NUMBER,
    p_talla VARCHAR2
) RETURN NUMBER IS
    v_stock NUMBER;
BEGIN
    SELECT stock_actual
    INTO v_stock
    FROM Inventario
    WHERE id_producto = p_id_producto
    AND talla = p_talla;

    RETURN NVL(v_stock,0);
END;
/

--Validar si se puede vender
CREATE OR REPLACE FUNCTION vender(
    p_id_producto NUMBER,
    p_talla VARCHAR2,
    p_cantidad NUMBER
) RETURN VARCHAR2 IS
    v_stock NUMBER;
BEGIN
    SELECT stock_actual
    INTO v_stock
    FROM Inventario
    WHERE id_producto = p_id_producto
    AND talla = p_talla;

    IF v_stock >= p_cantidad THEN
        RETURN 'SI';
    ELSE
        RETURN 'NO';
    END IF;
END;
/

--Nombre completo del cliente
CREATE OR REPLACE FUNCTION nombre_cliente(p_id_cliente NUMBER)
RETURN VARCHAR2 IS
    v_nombre VARCHAR2(200);
BEGIN
    SELECT nombre || ' ' || apellido
    INTO v_nombre
    FROM Clientes
    WHERE id_cliente = p_id_cliente;

    RETURN v_nombre;
END;
/

--Precio de un producto
CREATE OR REPLACE FUNCTION precio_producto(p_id_producto NUMBER)
RETURN NUMBER IS
    v_precio NUMBER;
BEGIN
    SELECT precio_venta
    INTO v_precio
    FROM Productos
    WHERE id_producto = p_id_producto;

    RETURN v_precio;
END;
/

--Cantidad de productos por categoría
CREATE OR REPLACE FUNCTION productos_categoria(p_categoria NUMBER)
RETURN NUMBER IS
    v_total NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_total
    FROM Productos
    WHERE id_categoria = p_categoria;

    RETURN v_total;
END;
/

--Calcular subtotal
CREATE OR REPLACE FUNCTION fn_subtotal(
    p_cantidad NUMBER,
    p_precio NUMBER
) RETURN NUMBER IS
BEGIN
    RETURN p_cantidad * p_precio;
END;
/

--Stock total de un producto
CREATE OR REPLACE FUNCTION stock_total(p_id_producto NUMBER)
RETURN NUMBER IS
    v_total NUMBER;
BEGIN
    SELECT SUM(stock_actual)
    INTO v_total
    FROM Inventario
    WHERE id_producto = p_id_producto;

    RETURN NVL(v_total,0);
END;
/
