import oracledb
import sys

# Conexión Oracle
instant_client_dir = r"C:\Users\ashji\Downloads\instantclient-basiclite-windows.x64-23.26.1.0.0\instantclient_23_0"
wallet_dir = r"C:\Users\ashji\Downloads\Wallet_DatabaseLBD"
dsn = "databaselbd_high"
user = "ADMIN"
password = "TiendaRopaLBDG7-"

def obtener_conexion():
    try:
        oracledb.init_oracle_client(lib_dir=instant_client_dir)
    except Exception:
        pass

    try:
        conn = oracledb.connect(
            user=user,
            password=password,
            dsn=dsn,
            config_dir=wallet_dir
        )
        return conn
    except oracledb.DatabaseError as e:
        print("Error de conexión:", e)
        sys.exit(1)