from flask import Flask, render_template
from clientes import clientes_bp
from categorias import categorias_bp
from detalle_facturas import detalle_facturas_bp
from detalle_ventas import detalle_ventas_bp
from facturas import facturas_bp
from historial_ventas import historial_ventas_bp
from inventario import inventario_bp
from productos import productos_bp
from ventas import ventas_bp

app = Flask(__name__,
            template_folder="../views",
            static_folder="../css",
            static_url_path="/css")

app.register_blueprint(clientes_bp)
app.register_blueprint(categorias_bp)
app.register_blueprint(detalle_facturas_bp)
app.register_blueprint(detalle_ventas_bp)
app.register_blueprint(facturas_bp)
app.register_blueprint(historial_ventas_bp)
app.register_blueprint(inventario_bp)
app.register_blueprint(productos_bp)
app.register_blueprint(ventas_bp)

@app.route("/")
def index():
    return render_template("index.html")

if __name__ == "__main__":
    app.run(debug=True)