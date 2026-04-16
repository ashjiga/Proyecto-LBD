--  PROCEDIMIENTOS ALMACENADOS
-- 1. Listar todos los clientes
CREATE OR REPLACE PROCEDURE GET_CLIENTES(C_CLIENTES OUT SYS_REFCURSOR) AS
BEGIN
    OPEN C_CLIENTES FOR
        SELECT id_cliente, nombre, apellido, telefono, email
        FROM   Clientes;
END;
/

-- 2. Insertar cliente
CREATE OR REPLACE PROCEDURE INSERTAR_CLIENTE(
    ID_IN       IN NUMBER,
    NOMBRE_IN   IN VARCHAR2,
    APELLIDO_IN IN VARCHAR2,
    TEL_IN      IN VARCHAR2,
    EMAIL_IN    IN VARCHAR2
) IS
BEGIN
    INSERT INTO Clientes (id_cliente, nombre, apellido, telefono, email)
    VALUES (ID_IN, NOMBRE_IN, APELLIDO_IN, TEL_IN, EMAIL_IN);
    COMMIT;
END;
/

-- 3. Modificar cliente
CREATE OR REPLACE PROCEDURE MODIFICA_CLIENTE(
    V_ID       IN NUMBER,
    V_NOMBRE   IN VARCHAR2,
    V_APELLIDO IN VARCHAR2,
    V_TEL      IN VARCHAR2,
    V_EMAIL    IN VARCHAR2
) AS
BEGIN
    UPDATE Clientes
    SET    nombre   = V_NOMBRE,
           apellido = V_APELLIDO,
           telefono = V_TEL,
           email    = V_EMAIL
    WHERE  id_cliente = V_ID;
    COMMIT;
END;
/

-- 4. Eliminar cliente
CREATE OR REPLACE PROCEDURE BORRAR_CLIENTE(ID_CLI IN NUMBER) AS
BEGIN
    DELETE FROM Clientes WHERE id_cliente = ID_CLI;
    COMMIT;
END;
/

-- 5. Listar categorías
CREATE OR REPLACE PROCEDURE SP_LISTAR_CATEGORIAS(CURSOR_CAT OUT SYS_REFCURSOR) AS
BEGIN
    OPEN CURSOR_CAT FOR
        SELECT id_categoria, nombre_categoria FROM Categorias;
END;
/

-- 6. Insertar categoría
CREATE OR REPLACE PROCEDURE ADD_CATEGORIA(
    ID_CAT  IN NUMBER,
    NOM_CAT IN VARCHAR2
) IS
BEGIN
    INSERT INTO Categorias (id_categoria, nombre_categoria)
    VALUES (ID_CAT, NOM_CAT);
    COMMIT;
END;
/

-- 7. Modificar categoría
CREATE OR REPLACE PROCEDURE UPDATE_CATEGORIA(
    ID_CAT  IN NUMBER,
    NOM_CAT IN VARCHAR2
) AS
BEGIN
    UPDATE Categorias
    SET    nombre_categoria = NOM_CAT
    WHERE  id_categoria = ID_CAT;
    COMMIT;
END;
/

-- 8. Eliminar categoría
CREATE OR REPLACE PROCEDURE ELIMINAR_CAT(ID_CAT IN NUMBER) IS
BEGIN
    DELETE FROM Categorias WHERE id_categoria = ID_CAT;
    COMMIT;
END;
/

-- 9. Listar productos con categoría
CREATE OR REPLACE PROCEDURE SP_LISTAR_PRODUCTOS_FULL(C_OUT OUT SYS_REFCURSOR) AS
BEGIN
    OPEN C_OUT FOR
        SELECT p.id_producto, p.nombre, p.descripcion,
               c.nombre_categoria, p.precio_venta, p.id_categoria
        FROM   Productos  p
        JOIN   Categorias c ON p.id_categoria = c.id_categoria
        ORDER  BY p.id_producto;
END;
/

-- 10. Insertar producto
CREATE OR REPLACE PROCEDURE SP_NUEVO_PRODUCTO(
    V_ID_PROD NUMBER,
    V_ID_CAT  NUMBER,
    V_NOMBRE  VARCHAR2,
    V_DESC    VARCHAR2,
    V_PRECIO  NUMBER
) AS
BEGIN
    INSERT INTO Productos (id_producto, id_categoria, nombre, descripcion, precio_venta)
    VALUES (V_ID_PROD, V_ID_CAT, V_NOMBRE, V_DESC, V_PRECIO);
    COMMIT;
END;
/

-- 11. Modificar producto
CREATE OR REPLACE PROCEDURE SP_EDITAR_PRODUCTO(
    V_ID_PROD NUMBER,
    V_ID_CAT  NUMBER,
    V_NOMBRE  VARCHAR2,
    V_DESC    VARCHAR2,
    V_PRECIO  NUMBER
) IS
BEGIN
    UPDATE Productos
    SET    id_categoria = V_ID_CAT,
           nombre       = V_NOMBRE,
           descripcion  = V_DESC,
           precio_venta = V_PRECIO
    WHERE  id_producto = V_ID_PROD;
    COMMIT;
END;
/

-- 12. Eliminar producto
CREATE OR REPLACE PROCEDURE SP_BORRAR_PRODUCTO(V_ID_PROD IN NUMBER) AS
BEGIN
    DELETE FROM Productos WHERE id_producto = V_ID_PROD;
    COMMIT;
END;
/

-- 13. Listar inventario completo
CREATE OR REPLACE PROCEDURE SP_LISTAR_INVENTARIO(C_OUT OUT SYS_REFCURSOR) AS
BEGIN
    OPEN C_OUT FOR
        SELECT i.id_inventario, p.nombre, i.talla,
               i.stock_actual, p.precio_venta
        FROM   Inventario i
        JOIN   Productos  p ON p.id_producto = i.id_producto;
END;
/

-- 14. Modificar stock de un ítem de inventario
CREATE OR REPLACE PROCEDURE SP_MODIFICAR_INVENTARIO(
    V_ID_INV IN NUMBER,
    V_STOCK  IN NUMBER
) AS
BEGIN
    IF V_STOCK < 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'El stock no puede ser negativo');
    END IF;
    UPDATE Inventario
    SET    stock_actual = V_STOCK
    WHERE  id_inventario = V_ID_INV;
    COMMIT;
END;
/

-- 15. Listar ventas con nombre de cliente
CREATE OR REPLACE PROCEDURE SP_LISTAR_VENTAS(C_OUT OUT SYS_REFCURSOR) AS
BEGIN
    OPEN C_OUT FOR
        SELECT v.id_venta,
               nombre_cliente(v.id_cliente),
               v.fecha,
               v.total
        FROM   Ventas v
        ORDER  BY v.id_venta DESC;
END;
/

-- 16. Listar facturas completas
CREATE OR REPLACE PROCEDURE SP_LISTAR_FACTURAS(C_OUT OUT SYS_REFCURSOR) AS
BEGIN
    OPEN C_OUT FOR
        SELECT f.id_factura, f.numero_factura,
               nombre_cliente(v.id_cliente),
               f.fecha_emision, f.total_factura, f.estado
        FROM   Facturas f
        JOIN   Ventas   v ON f.id_venta = v.id_venta
        ORDER  BY f.id_factura DESC;
END;
/

-- 17. Actualizar estado e impuesto de factura
CREATE OR REPLACE PROCEDURE SP_ACTUALIZAR_FACTURA(
    P_ID_FACTURA IN NUMBER,
    P_ESTADO     IN VARCHAR2,
    P_IMPUESTO   IN NUMBER
) AS
    V_SUBTOTAL NUMBER;
BEGIN
    SELECT subtotal INTO V_SUBTOTAL
    FROM   Facturas WHERE id_factura = P_ID_FACTURA;
    UPDATE Facturas
    SET    impuesto      = P_IMPUESTO,
           total_factura = V_SUBTOTAL + P_IMPUESTO,
           estado        = P_ESTADO
    WHERE  id_factura = P_ID_FACTURA;
    COMMIT;
END;
/

-- 18. Detalle completo de facturas con producto y talla
CREATE OR REPLACE PROCEDURE SP_DETALLE_FACTURAS_COMPLETO(C_OUT OUT SYS_REFCURSOR) AS
BEGIN
    OPEN C_OUT FOR
        SELECT f.numero_factura, f.estado,
               p.nombre, i.talla,
               df.cantidad, df.subtotal_linea
        FROM   Detalle_Facturas df
        JOIN   Facturas         f  ON df.id_factura    = f.id_factura
        JOIN   Inventario       i  ON df.id_inventario = i.id_inventario
        JOIN   Productos        p  ON i.id_producto    = p.id_producto
        ORDER  BY f.id_factura, df.id_detalle_fac;
END;
/

-- 19. Crear factura automática a partir de una venta
CREATE OR REPLACE PROCEDURE SP_CREAR_FACTURA(P_ID_VENTA IN NUMBER) AS
    V_TOTAL NUMBER;
BEGIN
    SELECT total INTO V_TOTAL FROM Ventas WHERE id_venta = P_ID_VENTA;
    INSERT INTO Facturas (id_factura, id_venta, numero_factura,
                          fecha_emision, subtotal, impuesto,
                          total_factura, estado)
    VALUES (SEQ_FACTURAS.NEXTVAL, P_ID_VENTA,
            'FAC-' || P_ID_VENTA, SYSDATE,
            V_TOTAL, 0, V_TOTAL, 'Pendiente');
    COMMIT;
END;
/

-- 20. Historial consolidado de ventas
CREATE OR REPLACE PROCEDURE SP_HISTORIAL_VENTAS(C_OUT OUT SYS_REFCURSOR) AS
BEGIN
    OPEN C_OUT FOR
        SELECT nombre_cliente(v.id_cliente) AS cliente,
               v.fecha,
               f.total_factura,
               f.numero_factura,
               SUM(dv.cantidad) AS cantidad_items,
               LISTAGG(p.nombre, ', ')
                   WITHIN GROUP (ORDER BY p.nombre) AS productos
        FROM   Ventas          v
        JOIN   Facturas        f  ON f.id_venta      = v.id_venta
        JOIN   Detalle_Ventas  dv ON dv.id_venta     = v.id_venta
        JOIN   Inventario      i  ON dv.id_inventario = i.id_inventario
        JOIN   Productos       p  ON i.id_producto   = p.id_producto
        GROUP  BY v.id_venta,
                  nombre_cliente(v.id_cliente),
                  v.fecha,
                  f.total_factura,
                  f.numero_factura
        ORDER  BY v.id_venta DESC;
END;
/

-- 21. Reporte de stock bajo
CREATE OR REPLACE PROCEDURE SP_STOCK_BAJO(
    V_UMBRAL IN  NUMBER,
    C_OUT    OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN C_OUT FOR
        SELECT p.nombre, i.talla, i.stock_actual
        FROM   Inventario i
        JOIN   Productos  p ON p.id_producto = i.id_producto
        WHERE  i.stock_actual < V_UMBRAL
        ORDER  BY i.stock_actual;
END;
/

-- 22. Detalle de una venta específica
CREATE OR REPLACE PROCEDURE SP_DETALLE_VENTA(
    V_ID_VENTA IN  NUMBER,
    C_OUT      OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN C_OUT FOR
        SELECT p.nombre, i.talla, dv.cantidad,
               dv.precio_unitario,
               dv.cantidad * dv.precio_unitario AS subtotal
        FROM   Detalle_Ventas dv
        JOIN   Inventario     i  ON i.id_inventario = dv.id_inventario
        JOIN   Productos      p  ON p.id_producto   = i.id_producto
        WHERE  dv.id_venta = V_ID_VENTA;
END;
/

-- 23. Ventas de un cliente específico con estado de factura
CREATE OR REPLACE PROCEDURE SP_VENTAS_POR_CLIENTE(
    V_ID_CLIENTE IN  NUMBER,
    C_OUT        OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN C_OUT FOR
        SELECT v.id_venta, v.fecha, v.total,
               f.numero_factura, f.estado
        FROM   Ventas   v
        JOIN   Facturas f ON f.id_venta = v.id_venta
        WHERE  v.id_cliente = V_ID_CLIENTE
        ORDER  BY v.fecha DESC;
END;
/

-- 24. Resumen de ventas de un día específico
CREATE OR REPLACE PROCEDURE SP_RESUMEN_VENTAS_FECHA(
    V_FECHA IN  DATE,
    C_OUT   OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN C_OUT FOR
        SELECT v.id_venta,
               nombre_cliente(v.id_cliente) AS cliente,
               v.total,
               f.numero_factura
        FROM   Ventas   v
        JOIN   Facturas f ON f.id_venta = v.id_venta
        WHERE  TRUNC(v.fecha) = TRUNC(V_FECHA)
        ORDER  BY v.id_venta;
END;
/

-- 25. Actualizar precio de un producto con validación
CREATE OR REPLACE PROCEDURE SP_ACTUALIZAR_PRECIO(
    V_ID_PROD IN NUMBER,
    V_PRECIO  IN NUMBER
) AS
BEGIN
    IF V_PRECIO <= 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'El precio debe ser mayor a cero');
    END IF;
    UPDATE Productos
    SET    precio_venta = V_PRECIO
    WHERE  id_producto  = V_ID_PROD;
    COMMIT;
END;
/