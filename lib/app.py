from flask import Flask, request, jsonify
from flask_cors import CORS
import json

app = Flask(__name__)
CORS(app)

@app.route('/ubicaciones', methods=['GET'])
def obtener_ubicaciones():
    try:
        # Leer el archivo Descripcion.txt
        ubicacion_descripcion = {}
        with open('Descripcion.txt', 'r', encoding='utf-8') as f:
            for line in f:
                partes = line.strip().split(';')
                if len(partes) == 2:
                    ubicacion, descripcion = partes[0].strip(), partes[1].strip()
                    ubicacion_descripcion[ubicacion] = descripcion

        # Preparar la respuesta JSON
        ubicaciones = list(ubicacion_descripcion.keys())
        respuesta = {
            'ubicaciones': ubicaciones,
            'ubicacion_descripcion': ubicacion_descripcion
        }
        return jsonify(respuesta), 200
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/guardar_reporte', methods=['POST'])
def guardar_reporte():
    try:
        data = request.get_json()
        # Aquí iría la lógica para guardar los datos en la base de datos
        print(data)  # Imprime los datos recibidos en la consola del servidor
        return jsonify({'mensaje': 'Reporte guardado exitosamente'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)