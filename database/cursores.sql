--  CURSORES
-- 1. Listar todos los productos con precio
DECLARE
    CURSOR c IS SELECT nombre, precio_venta FROM Productos;
BEGIN
    FOR r IN c LOOP
        DBMS_OUTPUT.PUT_LINE(r.nombre || ' — ₡' || r.precio_venta);
    END LOOP;
END;
/

-- 2. Listar todos los clientes
DECLARE
    CURSOR c IS SELECT nombre, apellido, email FROM Clientes;
BEGIN
    FOR r IN c LOOP
        DBMS_OUTPUT.PUT_LINE(r.nombre || ' ' || r.apellido || ' | ' || r.email);
    END LOOP;
END;
/

-- 3. Inventario con stock bajo
DECLARE
    CURSOR c IS
        SELECT p.nombre, i.talla, i.stock_actual
        FROM   Inventario i
        JOIN   Productos  p ON i.id_producto = p.id_producto
        WHERE  i.stock_actual < 10;
BEGIN
    FOR r IN c LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Stock bajo: ' || r.nombre ||
            ' T:' || r.talla || ' (' || r.stock_actual || ')'
        );
    END LOOP;
END;
/

-- 4. Detalle de todas las ventas
DECLARE
    CURSOR c IS
        SELECT dv.id_venta, p.nombre, dv.cantidad, dv.precio_unitario
        FROM   Detalle_Ventas dv
        JOIN   Inventario     i ON dv.id_inventario = i.id_inventario
        JOIN   Productos      p ON i.id_producto    = p.id_producto;
BEGIN
    FOR r IN c LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Venta ' || r.id_venta || ': ' || r.nombre || ' x' || r.cantidad
        );
    END LOOP;
END;
/

-- 5. Listar facturas con total y estado
DECLARE
    v_num    Facturas.numero_factura%TYPE;
    v_total  Facturas.total_factura%TYPE;
    v_estado Facturas.estado%TYPE;
    CURSOR c IS SELECT numero_factura, total_factura, estado FROM Facturas;
BEGIN
    OPEN c;
    LOOP
        FETCH c INTO v_num, v_total, v_estado;
        EXIT WHEN c%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_num || ' | ₡' || v_total || ' | ' || v_estado);
    END LOOP;
    CLOSE c;
END;
/

-- 6. Listar ventas con nombre del cliente 
DECLARE
    v_id_venta   Ventas.id_venta%TYPE;
    v_id_cliente Ventas.id_cliente%TYPE;
    v_total      Ventas.total%TYPE;
    CURSOR c IS SELECT id_venta, id_cliente, total FROM Ventas ORDER BY id_venta;
BEGIN
    OPEN c;
    LOOP
        FETCH c INTO v_id_venta, v_id_cliente, v_total;
        EXIT WHEN c%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(
            'Venta #' || v_id_venta ||
            ' | '     || nombre_cliente(v_id_cliente) ||
            ' | ₡'    || v_total
        );
    END LOOP;
    CLOSE c;
END;
/

-- 7. Productos agrupados por categoría
DECLARE
    CURSOR c IS
        SELECT p.nombre, c.nombre_categoria, p.precio_venta
        FROM   Productos  p
        JOIN   Categorias c ON c.id_categoria = p.id_categoria
        ORDER  BY c.nombre_categoria, p.nombre;
BEGIN
    FOR r IN c LOOP
        DBMS_OUTPUT.PUT_LINE(
            '[' || r.nombre_categoria || '] ' || r.nombre || ' ₡' || r.precio_venta
        );
    END LOOP;
END;
/

-- 8. Stock total agrupado por producto
DECLARE
    CURSOR c IS
        SELECT p.nombre, SUM(i.stock_actual) AS stock_total
        FROM   Inventario i
        JOIN   Productos  p ON p.id_producto = i.id_producto
        GROUP  BY p.nombre
        ORDER  BY stock_total DESC;
BEGIN
    FOR r IN c LOOP
        DBMS_OUTPUT.PUT_LINE(r.nombre || ': ' || r.stock_total || ' uds.');
    END LOOP;
END;
/

-- 9. Clientes sin ninguna compra registrada
DECLARE
    CURSOR c IS
        SELECT c.nombre, c.apellido
        FROM   Clientes c
        WHERE  NOT EXISTS (
            SELECT 1 FROM Ventas v WHERE v.id_cliente = c.id_cliente
        );
BEGIN
    FOR r IN c LOOP
        DBMS_OUTPUT.PUT_LINE('Sin compras: ' || r.nombre || ' ' || r.apellido);
    END LOOP;
END;
/

-- 10. Resumen de ventas por cliente 
DECLARE
    v_id    NUMBER;
    v_cnt   NUMBER;
    v_monto NUMBER;
    CURSOR c IS
        SELECT id_cliente, COUNT(*) AS n, SUM(total) AS monto
        FROM   Ventas
        GROUP  BY id_cliente;
BEGIN
    OPEN c;
    LOOP
        FETCH c INTO v_id, v_cnt, v_monto;
        EXIT WHEN c%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(
            nombre_cliente(v_id) || ': ' || v_cnt || ' ventas, ₡' || v_monto
        );
    END LOOP;
    CLOSE c;
END;
/

-- 11. Precio promedio por categoría
DECLARE
    v_cat  Categorias.nombre_categoria%TYPE;
    v_prom NUMBER;
    CURSOR c IS
        SELECT c.nombre_categoria, AVG(p.precio_venta) AS promedio
        FROM   Productos  p
        JOIN   Categorias c ON c.id_categoria = p.id_categoria
        GROUP  BY c.nombre_categoria;
BEGIN
    OPEN c;
    LOOP
        FETCH c INTO v_cat, v_prom;
        EXIT WHEN c%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_cat || ': promedio ₡' || ROUND(v_prom, 2));
    END LOOP;
    CLOSE c;
END;
/

-- 12. Detalle de facturas para una factura específica
DECLARE
    v_num_fac VARCHAR2(50) := 'FAC-01';
    CURSOR c IS
        SELECT df.descripcion_item, df.cantidad,
               df.precio_unitario, df.subtotal_linea
        FROM   Detalle_Facturas df
        JOIN   Facturas         f ON f.id_factura = df.id_factura
        WHERE  f.numero_factura = v_num_fac;
BEGIN
    DBMS_OUTPUT.PUT_LINE('-- Detalle: ' || v_num_fac);
    FOR r IN c LOOP
        DBMS_OUTPUT.PUT_LINE(
            '  ' || r.descripcion_item ||
            ' x' || r.cantidad || ' = ₡' || r.subtotal_linea
        );
    END LOOP;
END;
/

-- 13. Historial de ventas de un cliente específico
DECLARE
    v_id_cliente NUMBER := 1;
    CURSOR c IS
        SELECT fecha_venta, total_venta, numero_factura
        FROM   Historial_Ventas
        WHERE  id_cliente = v_id_cliente
        ORDER  BY fecha_venta DESC;
BEGIN
    FOR r IN c LOOP
        DBMS_OUTPUT.PUT_LINE(
            TO_CHAR(r.fecha_venta, 'DD/MM/YYYY') ||
            ' | ₡' || r.total_venta ||
            ' | '  || NVL(r.numero_factura, 'S/F')
        );
    END LOOP;
END;
/

-- 14. Productos con precio superior al promedio general
DECLARE
    v_promedio NUMBER;
    CURSOR c(p_promedio NUMBER) IS
        SELECT nombre, precio_venta
        FROM   Productos
        WHERE  precio_venta > p_promedio
        ORDER  BY precio_venta DESC;
BEGIN
    SELECT AVG(precio_venta) INTO v_promedio FROM Productos;
    DBMS_OUTPUT.PUT_LINE('Promedio general: ₡' || ROUND(v_promedio, 2));
    FOR r IN c(v_promedio) LOOP
        DBMS_OUTPUT.PUT_LINE(r.nombre || ' — ₡' || r.precio_venta);
    END LOOP;
END;
/

-- 15. Ventas del día con total acumulado
DECLARE
    v_acumulado NUMBER := 0;
    CURSOR c IS
        SELECT id_venta, id_cliente, total
        FROM   Ventas
        WHERE  TRUNC(fecha) = TRUNC(SYSDATE);
BEGIN
    FOR r IN c LOOP
        v_acumulado := v_acumulado + r.total;
        DBMS_OUTPUT.PUT_LINE(
            'Venta #' || r.id_venta ||
            ' — '     || nombre_cliente(r.id_cliente) ||
            ' | ₡'    || r.total
        );
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('TOTAL DEL DÍA: ₡' || v_acumulado);
END;
/