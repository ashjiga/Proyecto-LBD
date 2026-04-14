from flask import Flask, render_template
from clientes import clientes_bp

app = Flask(__name__,
template_folder="../views",
static_folder="../css",
static_url_path="/css")

app.register_blueprint(clientes_bp)

@app.route("/")
def index():
    return render_template("index.html")  
if __name__ == "__main__":
    app.run(debug=True)