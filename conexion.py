import oracledb
import getpass
import os
import sys

instant_client_dir = os.getenv("ORACLE_CLIENT")
wallet_dir = os.getenv("ORACLE_WALLET")

dsn = "databaselbd_high"
user = "ADMIN"

def obtener_conexion():
    try:
        if instant_client_dir:
            oracledb.init_oracle_client(lib_dir=instant_client_dir)
    except Exception:
        pass

    password = getpass.getpass(f"Ingrese la contraseña para {user}: ")

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