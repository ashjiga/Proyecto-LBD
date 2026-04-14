from flask import Flask
from clientes import clientes_bp

app = Flask(__name__, template_folder="../views")

app.register_blueprint(clientes_bp)

@app.route("/")
def index():
    return "<h1>Inicio</h1><a href='/clientes'>Ir a Clientes</a>"

if __name__ == "__main__":
    app.run(debug=True)