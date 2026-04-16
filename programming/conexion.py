import oracledb
import sys

# Conexión Oracle
instant_client_dir = r""
wallet_dir = r""
dsn = "databaselbd_high"
user = "ADMIN"
password = ""

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