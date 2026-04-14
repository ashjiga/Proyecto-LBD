--Paquetes--
--Package clientes
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

--Agregar cliente
    PROCEDURE agregar_cliente(
        p_nombre   VARCHAR2,
        p_apellido VARCHAR2,
        p_telefono VARCHAR2,
        p_email    VARCHAR2
    ) IS
    BEGIN
        INSERT INTO Clientes (nombre, apellido, telefono, email)
        VALUES (p_nombre, p_apellido, p_telefono, p_email);
        COMMIT;
    END agregar_cliente;

--Listar clientes
    PROCEDURE listar_clientes IS
        v_cursor SYS_REFCURSOR;
        v_id     Clientes.id_cliente%TYPE;
        v_nom    Clientes.nombre%TYPE;
        v_ape    Clientes.apellido%TYPE;
        v_tel    Clientes.telefono%TYPE;
        v_email  Clientes.email%TYPE;
    BEGIN
        GET_CLIENTES(v_cursor);
        LOOP
            FETCH v_cursor INTO v_id, v_nom, v_ape, v_tel, v_email;
            EXIT WHEN v_cursor%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('Cliente: ' || v_nom || ' ' || v_ape);
        END LOOP;
        CLOSE v_cursor;
    END listar_clientes;

END pkg_clientes;
/


--Package productos
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

--Agregar producto
    PROCEDURE agregar_producto(
        p_nombre    VARCHAR2,
        p_desc      VARCHAR2,
        p_precio    NUMBER,
        p_categoria NUMBER
    ) IS
    BEGIN
        INSERT INTO Productos (nombre, descripcion, precio_venta, id_categoria)
        VALUES (p_nombre, p_desc, p_precio, p_categoria);
        COMMIT;
    END agregar_producto;

--Listar productos
    PROCEDURE listar_productos IS
        v_cursor  SYS_REFCURSOR;
        v_id      Productos.id_producto%TYPE;
        v_id_cat  Productos.id_categoria%TYPE;
        v_nombre  Productos.nombre%TYPE;
        v_desc    Productos.descripcion%TYPE;
        v_precio  Productos.precio_venta%TYPE;
    BEGIN
        VER_PRODUCTOS(v_cursor);
        LOOP
            FETCH v_cursor INTO v_id, v_id_cat, v_nombre, v_desc, v_precio;
            EXIT WHEN v_cursor%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('Producto: ' || v_nombre || ' - ₡' || v_precio);
        END LOOP;
        CLOSE v_cursor;
    END listar_productos;

END pkg_productos;
/


--Package inventario
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

--Agregar stock
    PROCEDURE agregar_stock(
        p_producto NUMBER,
        p_talla    VARCHAR2,
        p_stock    NUMBER
    ) IS
    BEGIN
        INSERT INTO Inventario (id_producto, talla, stock_actual)
        VALUES (p_producto, p_talla, p_stock);
        COMMIT;
    END agregar_stock;

--Consultar stock
    PROCEDURE consultar_stock(p_producto NUMBER) IS
        v_cursor  SYS_REFCURSOR;
        v_id_inv  Inventario.id_inventario%TYPE;
        v_id_prod Inventario.id_producto%TYPE;
        v_talla   Inventario.talla%TYPE;
        v_stock   Inventario.stock_actual%TYPE;
    BEGIN
        REPORTE_INVENTARIO(v_cursor);
        LOOP
            FETCH v_cursor INTO v_id_inv, v_id_prod, v_talla, v_stock;
            EXIT WHEN v_cursor%NOTFOUND;
            IF v_id_prod = p_producto THEN
                DBMS_OUTPUT.PUT_LINE('Talla: ' || v_talla || ' | Stock: ' || v_stock);
            END IF;
        END LOOP;
        CLOSE v_cursor;
    END consultar_stock;

END pkg_inventario;
/


--Package ventas
CREATE OR REPLACE PACKAGE pkg_ventas AS
    PROCEDURE crear_venta(p_cliente NUMBER);
    PROCEDURE agregar_detalle(
        p_venta      NUMBER,
        p_inventario NUMBER,
        p_cantidad   NUMBER,
        p_precio     NUMBER
    );
END pkg_ventas;
/

CREATE OR REPLACE PACKAGE BODY pkg_ventas AS

--Crear venta
    PROCEDURE crear_venta(p_cliente NUMBER) IS
    BEGIN
        INSERT INTO Ventas (id_cliente, fecha, total)
        VALUES (p_cliente, SYSDATE, 0);
        COMMIT;
    END crear_venta;

--Agregar detalle de venta
    PROCEDURE agregar_detalle(
        p_venta      NUMBER,
        p_inventario NUMBER,
        p_cantidad   NUMBER,
        p_precio     NUMBER
    ) IS
    BEGIN
        INSERT INTO Detalle_Ventas (id_venta, id_inventario, cantidad, precio_unitario)
        VALUES (p_venta, p_inventario, p_cantidad, p_precio);

        UPDATE Ventas
        SET total = total + fn_subtotal(p_cantidad, p_precio)
        WHERE id_venta = p_venta;

        COMMIT;
    END agregar_detalle;

END pkg_ventas;
/


--Package facturación
CREATE OR REPLACE PACKAGE pkg_facturacion AS
    FUNCTION calcular_total(p_venta NUMBER) RETURN NUMBER;
    PROCEDURE generar_factura(p_venta NUMBER);
END pkg_facturacion;
/

CREATE OR REPLACE PACKAGE BODY pkg_facturacion AS

--Calcular total de venta
    FUNCTION calcular_total(p_venta NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN fn_total_venta(p_venta);
    END calcular_total;

--Generar factura
    PROCEDURE generar_factura(p_venta NUMBER) IS
        v_total NUMBER;
    BEGIN
        v_total := calcular_total(p_venta);
        DBMS_OUTPUT.PUT_LINE('Factura - Venta #' || p_venta);
        DBMS_OUTPUT.PUT_LINE('Total: ₡' || v_total);
    END generar_factura;

END pkg_facturacion;
/