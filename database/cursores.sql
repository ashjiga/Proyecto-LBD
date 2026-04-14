--Cursores--
--Listar productos
DECLARE
  v_nombre  Productos.nombre%TYPE;
  v_precio  Productos.precio_venta%TYPE;

  CURSOR c_productos IS
    SELECT nombre, precio_venta
    FROM Productos;
BEGIN
  OPEN c_productos;

  LOOP
    FETCH c_productos INTO v_nombre, v_precio;
    EXIT WHEN c_productos%NOTFOUND;

    DBMS_OUTPUT.PUT_LINE('Producto: ' || v_nombre || ' Precio: ' || v_precio);
  END LOOP;

  CLOSE c_productos;
END;
/

--Listar clientes
DECLARE
  CURSOR c_clientes IS
    SELECT nombre, apellido
    FROM Clientes;
BEGIN
  FOR r IN c_clientes LOOP
    DBMS_OUTPUT.PUT_LINE('Cliente: ' || r.nombre || ' ' || r.apellido);
  END LOOP;
END;
/

--Listar productos
DECLARE
BEGIN
  FOR r IN (SELECT nombre, precio_venta FROM Productos) LOOP
    DBMS_OUTPUT.PUT_LINE(r.nombre || ' ₡' || r.precio_venta);
  END LOOP;
END;
/

--Inventario bajo
DECLARE
  CURSOR c_stock IS
    SELECT p.nombre, i.talla, i.stock_actual
    FROM Inventario i
    JOIN Productos p ON i.id_producto = p.id_producto;
BEGIN
  FOR r IN c_stock LOOP
    IF r.stock_actual < 10 THEN
      DBMS_OUTPUT.PUT_LINE('Stock bajo: ' || r.nombre || ' Talla ' || r.talla);
    END IF;
  END LOOP;
END;
/

--Detalle de ventas
DECLARE
  CURSOR c_detalle IS
    SELECT dv.id_venta, p.nombre, dv.cantidad
    FROM Detalle_Ventas dv
    JOIN Inventario i ON dv.id_inventario = i.id_inventario
    JOIN Productos p ON i.id_producto = p.id_producto;
BEGIN
  FOR r IN c_detalle LOOP
    DBMS_OUTPUT.PUT_LINE('Venta ' || r.id_venta || ': ' || r.nombre || ' x' || r.cantidad);
  END LOOP;
END;
/

--Listar facturas
DECLARE
  CURSOR c_facturas IS
    SELECT numero_factura, total_factura
    FROM Facturas;
BEGIN
  FOR r IN c_facturas LOOP
    DBMS_OUTPUT.PUT_LINE('Factura: ' || r.numero_factura || ' Total: ' || r.total_factura);
  END LOOP;
END;
/

--Listar ventas
DECLARE
    CURSOR c_ventas IS
        SELECT 
            ID_VENTA,
            ID_CLIENTE,
            FECHA,
            TOTAL
        FROM VENTAS;

    v_id_venta VENTAS.ID_VENTA%TYPE;
    v_id_cliente VENTAS.ID_CLIENTE%TYPE;
    v_fecha VENTAS.FECHA%TYPE;
    v_total VENTAS.TOTAL%TYPE;

BEGIN
    OPEN c_ventas;

    LOOP
        FETCH c_ventas INTO v_id_venta, v_id_cliente, v_fecha, v_total;
        EXIT WHEN c_ventas%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Venta: ' || v_id_venta || ' Total: ' || v_total);
    END LOOP;

    CLOSE c_ventas;
END;
/

--Inventario completo
DECLARE
  CURSOR c_inventario IS
    SELECT p.nombre, i.talla, i.stock_actual
    FROM Inventario i
    JOIN Productos p ON i.id_producto = p.id_producto;
BEGIN
  FOR r IN c_inventario LOOP
    DBMS_OUTPUT.PUT_LINE('Producto: ' || r.nombre || ' Talla: ' || r.talla || ' Stock: ' || r.stock_actual);
  END LOOP;
END;
/