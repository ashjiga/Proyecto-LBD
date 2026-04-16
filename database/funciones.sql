--  FUNCIONES
-- 1. Nombre completo del cliente
CREATE OR REPLACE FUNCTION nombre_cliente(p_id_cliente NUMBER)
RETURN VARCHAR2 IS
    v_nombre VARCHAR2(200);
BEGIN
    SELECT nombre || ' ' || apellido
    INTO   v_nombre
    FROM   Clientes
    WHERE  id_cliente = p_id_cliente;
    RETURN v_nombre;
END;
/

-- 2. Total calculado de una venta
CREATE OR REPLACE FUNCTION fn_total_venta(p_id_venta NUMBER)
RETURN NUMBER IS
    v_total NUMBER;
BEGIN
    SELECT SUM(cantidad * precio_unitario)
    INTO   v_total
    FROM   Detalle_Ventas
    WHERE  id_venta = p_id_venta;
    RETURN NVL(v_total, 0);
END;
/

-- 3. Precio de un ítem de inventario
CREATE OR REPLACE FUNCTION precio_por_inventario(p_id_inventario NUMBER)
RETURN NUMBER IS
    v_precio NUMBER;
BEGIN
    SELECT p.precio_venta
    INTO   v_precio
    FROM   Inventario i
    JOIN   Productos  p ON p.id_producto = i.id_producto
    WHERE  i.id_inventario = p_id_inventario;
    RETURN v_precio;
END;
/

-- 4. Próximo ID de categoría
CREATE OR REPLACE FUNCTION FN_NUEVO_ID_CATEGORIA
RETURN NUMBER IS
    v_id NUMBER;
BEGIN
    SELECT NVL(MAX(id_categoria), 0) + 1
    INTO   v_id
    FROM   Categorias;
    RETURN v_id;
END;
/

-- 5. Próximo ID de cliente
CREATE OR REPLACE FUNCTION FN_NUEVO_ID_CLIENTE
RETURN NUMBER IS
    v_id NUMBER;
BEGIN
    SELECT NVL(MAX(id_cliente), 0) + 1
    INTO   v_id
    FROM   Clientes;
    RETURN v_id;
END;
/

-- 6. Próximo ID de producto
CREATE OR REPLACE FUNCTION FN_NUEVO_ID_PRODUCTO
RETURN NUMBER IS
    v_id NUMBER;
BEGIN
    SELECT NVL(MAX(id_producto), 0) + 1
    INTO   v_id
    FROM   Productos;
    RETURN v_id;
END;
/

-- 7. Stock disponible por producto y talla
CREATE OR REPLACE FUNCTION stock_disponible(
    p_id_producto NUMBER,
    p_talla       VARCHAR2
) RETURN NUMBER IS
    v_stock NUMBER;
BEGIN
    SELECT stock_actual
    INTO   v_stock
    FROM   Inventario
    WHERE  id_producto = p_id_producto
      AND  talla       = p_talla;
    RETURN NVL(v_stock, 0);
END;
/

-- 8. Stock total de todas las tallas de un producto
CREATE OR REPLACE FUNCTION stock_total(p_id_producto NUMBER)
RETURN NUMBER IS
    v_total NUMBER;
BEGIN
    SELECT SUM(stock_actual)
    INTO   v_total
    FROM   Inventario
    WHERE  id_producto = p_id_producto;
    RETURN NVL(v_total, 0);
END;
/

-- 9. Validar si hay stock suficiente para vender
CREATE OR REPLACE FUNCTION fn_puede_vender(
    p_id_producto NUMBER,
    p_talla       VARCHAR2,
    p_cantidad    NUMBER
) RETURN VARCHAR2 IS
    v_stock NUMBER;
BEGIN
    SELECT stock_actual
    INTO   v_stock
    FROM   Inventario
    WHERE  id_producto = p_id_producto
      AND  talla       = p_talla;
    RETURN CASE WHEN v_stock >= p_cantidad THEN 'SI' ELSE 'NO' END;
END;
/

-- 10. Total acumulado de ventas de un cliente
CREATE OR REPLACE FUNCTION fn_total_cliente(p_id_cliente NUMBER)
RETURN NUMBER IS
    v_total NUMBER;
BEGIN
    SELECT NVL(SUM(total), 0)
    INTO   v_total
    FROM   Ventas
    WHERE  id_cliente = p_id_cliente;
    RETURN v_total;
END;
/

-- 11. Número de ventas realizadas por un cliente
CREATE OR REPLACE FUNCTION fn_num_ventas_cliente(p_id_cliente NUMBER)
RETURN NUMBER IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO   v_count
    FROM   Ventas
    WHERE  id_cliente = p_id_cliente;
    RETURN v_count;
END;
/

-- 12. Precio promedio de los productos de una categoría
CREATE OR REPLACE FUNCTION fn_promedio_precio_cat(p_id_categoria NUMBER)
RETURN NUMBER IS
    v_promedio NUMBER;
BEGIN
    SELECT NVL(AVG(precio_venta), 0)
    INTO   v_promedio
    FROM   Productos
    WHERE  id_categoria = p_id_categoria;
    RETURN ROUND(v_promedio, 2);
END;
/

-- 13. Aplicar descuento porcentual sobre un precio
CREATE OR REPLACE FUNCTION fn_aplicar_descuento(
    p_precio   NUMBER,
    p_pct_desc NUMBER
) RETURN NUMBER IS
BEGIN
    IF p_pct_desc < 0 OR p_pct_desc > 100 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Porcentaje de descuento inválido');
    END IF;
    RETURN ROUND(p_precio * (1 - p_pct_desc / 100), 2);
END;
/

-- 14. Calcular subtotal de una línea
CREATE OR REPLACE FUNCTION fn_subtotal(
    p_cantidad NUMBER,
    p_precio   NUMBER
) RETURN NUMBER IS
BEGIN
    RETURN p_cantidad * p_precio;
END;
/

-- 15. Obtener número de factura asociada a una venta
CREATE OR REPLACE FUNCTION fn_numero_factura(p_id_venta NUMBER)
RETURN VARCHAR2 IS
    v_num VARCHAR2(50);
BEGIN
    SELECT numero_factura
    INTO   v_num
    FROM   Facturas
    WHERE  id_venta = p_id_venta
      AND  ROWNUM   = 1;
    RETURN NVL(v_num, 'SIN FACTURA');
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN 'SIN FACTURA';
END;
/