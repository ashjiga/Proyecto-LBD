--  PAQUETES
-- 1. PKG_VENTAS
CREATE OR REPLACE PACKAGE PKG_VENTAS AS
    PROCEDURE CREAR_VENTA(
        p_id_cliente IN  NUMBER,
        p_id_venta   OUT NUMBER
    );
    PROCEDURE AGREGAR_DETALLE(
        p_id_venta      NUMBER,
        p_id_inventario NUMBER,
        p_cantidad      NUMBER,
        p_precio        NUMBER
    );
END PKG_VENTAS;
/

CREATE OR REPLACE PACKAGE BODY PKG_VENTAS AS

    PROCEDURE CREAR_VENTA(
        p_id_cliente IN  NUMBER,
        p_id_venta   OUT NUMBER
    ) IS
    BEGIN
        INSERT INTO Ventas (id_venta, id_cliente, fecha, total)
        VALUES (SEQ_VENTAS.NEXTVAL, p_id_cliente, SYSDATE, 0)
        RETURNING id_venta INTO p_id_venta;
    END CREAR_VENTA;

    PROCEDURE AGREGAR_DETALLE(
        p_id_venta      NUMBER,
        p_id_inventario NUMBER,
        p_cantidad      NUMBER,
        p_precio        NUMBER
    ) IS
    BEGIN
        INSERT INTO Detalle_Ventas (id_detalle, id_inventario,
                                    id_venta, cantidad, precio_unitario)
        VALUES (SEQ_DETALLE_VENTAS.NEXTVAL,
                p_id_inventario, p_id_venta, p_cantidad, p_precio);
        UPDATE Ventas
        SET    total = total + (p_cantidad * p_precio)
        WHERE  id_venta = p_id_venta;
        UPDATE Inventario
        SET    stock_actual = stock_actual - p_cantidad
        WHERE  id_inventario = p_id_inventario;
    END AGREGAR_DETALLE;

END PKG_VENTAS;
/

-- 2. PKG_CLIENTES
CREATE OR REPLACE PACKAGE pkg_clientes AS
    PROCEDURE agregar_cliente(
        p_nombre   VARCHAR2,
        p_apellido VARCHAR2,
        p_telefono VARCHAR2,
        p_email    VARCHAR2
    );
    PROCEDURE listar_clientes;
END pkg_clientes;
/

CREATE OR REPLACE PACKAGE BODY pkg_clientes AS

    PROCEDURE agregar_cliente(
        p_nombre   VARCHAR2,
        p_apellido VARCHAR2,
        p_telefono VARCHAR2,
        p_email    VARCHAR2
    ) IS
        v_id NUMBER;
    BEGIN
        v_id := FN_NUEVO_ID_CLIENTE;
        INSERT INTO Clientes (id_cliente, nombre, apellido, telefono, email)
        VALUES (v_id, p_nombre, p_apellido, p_telefono, p_email);
        COMMIT;
    END agregar_cliente;

    PROCEDURE listar_clientes IS
        CURSOR c IS SELECT nombre, apellido FROM Clientes;
    BEGIN
        FOR r IN c LOOP
            DBMS_OUTPUT.PUT_LINE(r.nombre || ' ' || r.apellido);
        END LOOP;
    END listar_clientes;

END pkg_clientes;
/

-- 3. PKG_PRODUCTOS
CREATE OR REPLACE PACKAGE pkg_productos AS
    PROCEDURE agregar_producto(
        p_nombre    VARCHAR2,
        p_desc      VARCHAR2,
        p_precio    NUMBER,
        p_categoria NUMBER
    );
    PROCEDURE listar_productos;
END pkg_productos;
/

CREATE OR REPLACE PACKAGE BODY pkg_productos AS

    PROCEDURE agregar_producto(
        p_nombre    VARCHAR2,
        p_desc      VARCHAR2,
        p_precio    NUMBER,
        p_categoria NUMBER
    ) IS
        v_id NUMBER;
    BEGIN
        v_id := FN_NUEVO_ID_PRODUCTO;
        INSERT INTO Productos (id_producto, id_categoria, nombre, descripcion, precio_venta)
        VALUES (v_id, p_categoria, p_nombre, p_desc, p_precio);
        COMMIT;
    END agregar_producto;

    PROCEDURE listar_productos IS
        CURSOR c IS SELECT nombre, precio_venta FROM Productos;
    BEGIN
        FOR r IN c LOOP
            DBMS_OUTPUT.PUT_LINE(r.nombre || ' — ₡' || r.precio_venta);
        END LOOP;
    END listar_productos;

END pkg_productos;
/

-- 4. PKG_INVENTARIO
CREATE OR REPLACE PACKAGE pkg_inventario AS
    PROCEDURE agregar_stock(
        p_producto NUMBER,
        p_talla    VARCHAR2,
        p_stock    NUMBER
    );
    PROCEDURE consultar_stock(p_producto NUMBER);
END pkg_inventario;
/

CREATE OR REPLACE PACKAGE BODY pkg_inventario AS

    PROCEDURE agregar_stock(
        p_producto NUMBER,
        p_talla    VARCHAR2,
        p_stock    NUMBER
    ) IS
    BEGIN
        IF p_stock < 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'El stock no puede ser negativo');
        END IF;
        INSERT INTO Inventario (id_inventario, id_producto, talla, stock_actual)
        VALUES (SEQ_HISTORIAL_VENTAS.NEXTVAL, p_producto, p_talla, p_stock);
        COMMIT;
    END agregar_stock;

    PROCEDURE consultar_stock(p_producto NUMBER) IS
        CURSOR c IS
            SELECT talla, stock_actual FROM Inventario
            WHERE  id_producto = p_producto;
    BEGIN
        FOR r IN c LOOP
            DBMS_OUTPUT.PUT_LINE('Talla: ' || r.talla || ' | Stock: ' || r.stock_actual);
        END LOOP;
    END consultar_stock;

END pkg_inventario;
/

-- 5. PKG_FACTURACION
CREATE OR REPLACE PACKAGE pkg_facturacion AS
    FUNCTION  calcular_total(p_venta NUMBER) RETURN NUMBER;
    PROCEDURE generar_factura(p_venta NUMBER);
END pkg_facturacion;
/

CREATE OR REPLACE PACKAGE BODY pkg_facturacion AS

    FUNCTION calcular_total(p_venta NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN fn_total_venta(p_venta);
    END calcular_total;

    PROCEDURE generar_factura(p_venta NUMBER) IS
        v_total NUMBER;
    BEGIN
        v_total := calcular_total(p_venta);
        DBMS_OUTPUT.PUT_LINE('Venta #' || p_venta || ' — Total: ₡' || v_total);
    END generar_factura;

END pkg_facturacion;
/

-- 6. PKG_CATEGORIAS
CREATE OR REPLACE PACKAGE pkg_categorias AS
    PROCEDURE agregar_categoria(p_nombre VARCHAR2);
    PROCEDURE listar_categorias;
    FUNCTION  total_categorias RETURN NUMBER;
END pkg_categorias;
/

CREATE OR REPLACE PACKAGE BODY pkg_categorias AS

    PROCEDURE agregar_categoria(p_nombre VARCHAR2) IS
        v_id NUMBER;
    BEGIN
        v_id := FN_NUEVO_ID_CATEGORIA;
        INSERT INTO Categorias (id_categoria, nombre_categoria)
        VALUES (v_id, p_nombre);
        COMMIT;
    END agregar_categoria;

    PROCEDURE listar_categorias IS
        CURSOR c IS SELECT id_categoria, nombre_categoria FROM Categorias;
    BEGIN
        FOR r IN c LOOP
            DBMS_OUTPUT.PUT_LINE(r.id_categoria || '. ' || r.nombre_categoria);
        END LOOP;
    END listar_categorias;

    FUNCTION total_categorias RETURN NUMBER IS
        v_total NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_total FROM Categorias;
        RETURN v_total;
    END total_categorias;

END pkg_categorias;
/

-- 7. PKG_REPORTES
CREATE OR REPLACE PACKAGE pkg_reportes AS
    PROCEDURE reporte_ventas_del_dia;
    PROCEDURE reporte_stock_bajo(p_umbral NUMBER);
    FUNCTION  ventas_totales_periodo(p_inicio DATE, p_fin DATE) RETURN NUMBER;
END pkg_reportes;
/

CREATE OR REPLACE PACKAGE BODY pkg_reportes AS

    PROCEDURE reporte_ventas_del_dia IS
        CURSOR c IS
            SELECT id_venta, id_cliente, total
            FROM   Ventas
            WHERE  TRUNC(fecha) = TRUNC(SYSDATE);
    BEGIN
        FOR r IN c LOOP
            DBMS_OUTPUT.PUT_LINE(
                'Venta #' || r.id_venta ||
                ' | '     || nombre_cliente(r.id_cliente) ||
                ' | ₡'    || r.total
            );
        END LOOP;
    END reporte_ventas_del_dia;

    PROCEDURE reporte_stock_bajo(p_umbral NUMBER) IS
        v_cursor SYS_REFCURSOR;
        v_nombre Productos.nombre%TYPE;
        v_talla  Inventario.talla%TYPE;
        v_stock  Inventario.stock_actual%TYPE;
    BEGIN
        SP_STOCK_BAJO(p_umbral, v_cursor);
        LOOP
            FETCH v_cursor INTO v_nombre, v_talla, v_stock;
            EXIT WHEN v_cursor%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(v_nombre || ' T:' || v_talla || ' — ' || v_stock);
        END LOOP;
        CLOSE v_cursor;
    END reporte_stock_bajo;

    FUNCTION ventas_totales_periodo(p_inicio DATE, p_fin DATE) RETURN NUMBER IS
        v_total NUMBER;
    BEGIN
        SELECT NVL(SUM(total), 0)
        INTO   v_total
        FROM   Ventas
        WHERE  fecha BETWEEN p_inicio AND p_fin;
        RETURN v_total;
    END ventas_totales_periodo;

END pkg_reportes;
/

-- 8. PKG_DETALLE_VENTAS
CREATE OR REPLACE PACKAGE pkg_detalle_ventas AS
    PROCEDURE ver_detalle(p_id_venta NUMBER);
    FUNCTION  subtotal_venta(p_id_venta NUMBER) RETURN NUMBER;
END pkg_detalle_ventas;
/

CREATE OR REPLACE PACKAGE BODY pkg_detalle_ventas AS

    PROCEDURE ver_detalle(p_id_venta NUMBER) IS
        v_cursor SYS_REFCURSOR;
        v_nombre Productos.nombre%TYPE;
        v_talla  Inventario.talla%TYPE;
        v_cant   Detalle_Ventas.cantidad%TYPE;
        v_precio Detalle_Ventas.precio_unitario%TYPE;
        v_sub    NUMBER;
    BEGIN
        SP_DETALLE_VENTA(p_id_venta, v_cursor);
        LOOP
            FETCH v_cursor INTO v_nombre, v_talla, v_cant, v_precio, v_sub;
            EXIT WHEN v_cursor%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(
                v_nombre || ' (' || v_talla || ') x' || v_cant || ' = ₡' || v_sub
            );
        END LOOP;
        CLOSE v_cursor;
    END ver_detalle;

    FUNCTION subtotal_venta(p_id_venta NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN fn_total_venta(p_id_venta);
    END subtotal_venta;

END pkg_detalle_ventas;
/

-- 9. PKG_HISTORIAL
CREATE OR REPLACE PACKAGE pkg_historial AS
    PROCEDURE ver_historial_cliente(p_id_cliente NUMBER);
    FUNCTION  ultima_venta_cliente(p_id_cliente NUMBER) RETURN DATE;
END pkg_historial;
/

CREATE OR REPLACE PACKAGE BODY pkg_historial AS

    PROCEDURE ver_historial_cliente(p_id_cliente NUMBER) IS
        CURSOR c IS
            SELECT id_historico, fecha_venta, total_venta, numero_factura
            FROM   Historial_Ventas
            WHERE  id_cliente = p_id_cliente
            ORDER  BY fecha_venta DESC;
    BEGIN
        FOR r IN c LOOP
            DBMS_OUTPUT.PUT_LINE(
                '#'  || r.id_historico ||
                ' | ' || TO_CHAR(r.fecha_venta, 'DD/MM/YYYY') ||
                ' | ₡' || r.total_venta ||
                ' | ' || NVL(r.numero_factura, 'S/F')
            );
        END LOOP;
    END ver_historial_cliente;

    FUNCTION ultima_venta_cliente(p_id_cliente NUMBER) RETURN DATE IS
        v_fecha DATE;
    BEGIN
        SELECT MAX(fecha)
        INTO   v_fecha
        FROM   Ventas
        WHERE  id_cliente = p_id_cliente;
        RETURN v_fecha;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN NULL;
    END ultima_venta_cliente;

END pkg_historial;
/

-- 10. PKG_UTILIDADES
CREATE OR REPLACE PACKAGE pkg_utilidades AS
    FUNCTION  formatear_precio(p_precio NUMBER) RETURN VARCHAR2;
    PROCEDURE mostrar_info_producto(p_id_prod NUMBER);
    FUNCTION  cliente_activo(p_id_cliente NUMBER) RETURN VARCHAR2;
END pkg_utilidades;
/

CREATE OR REPLACE PACKAGE BODY pkg_utilidades AS

    FUNCTION formatear_precio(p_precio NUMBER) RETURN VARCHAR2 IS
    BEGIN
        RETURN '₡' || TO_CHAR(p_precio, 'FM999,999,990.00');
    END formatear_precio;

    PROCEDURE mostrar_info_producto(p_id_prod NUMBER) IS
        v_nombre Productos.nombre%TYPE;
        v_precio Productos.precio_venta%TYPE;
    BEGIN
        SELECT nombre, precio_venta
        INTO   v_nombre, v_precio
        FROM   Productos
        WHERE  id_producto = p_id_prod;
        DBMS_OUTPUT.PUT_LINE('Producto : ' || v_nombre);
        DBMS_OUTPUT.PUT_LINE('Precio   : ' || formatear_precio(v_precio));
        DBMS_OUTPUT.PUT_LINE('Stock    : ' || stock_total(p_id_prod) || ' unidades');
    END mostrar_info_producto;

    FUNCTION cliente_activo(p_id_cliente NUMBER) RETURN VARCHAR2 IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO   v_count
        FROM   Ventas
        WHERE  id_cliente  = p_id_cliente
          AND  TRUNC(fecha) >= ADD_MONTHS(TRUNC(SYSDATE), -6);
        RETURN CASE WHEN v_count > 0 THEN 'ACTIVO' ELSE 'INACTIVO' END;
    END cliente_activo;

END pkg_utilidades;
/