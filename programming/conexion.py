import oracledb
import getpass
import sys

instant_client_dir = r"" #Entre las comillas deben poner la ruta del archivo Instant Client
wallet_dir = r"" #Entre las comillas deben poner la ruta del archivo Wallet descomprimido
dsn = "databaselbd_high"
user = "ADMIN"

def obtener_conexion():
    try:
        oracledb.init_oracle_client(lib_dir=instant_client_dir)
    except Exception:
        pass

    password = getpass.getpass(f"Ingresa la contraseña para {user}: ")

    try:
        conn = oracledb.connect(user=user, password=password, dsn=dsn, config_dir=wallet_dir)
        return conn
    except oracledb.DatabaseError as e:
        print("Error de conexión:", e)
        sys.exit(1)