from flask import Flask, request, jsonify
import pandas as pd
from datetime import datetime

app = Flask(__name__)

FILE = "cleaned_data.csv"

@app.route('/add', methods=['POST'])
def add():
    data = request.json

    new_data = {
        "Date": datetime.now(),
        "Educational_level": data.get("Educational_level", "Unknown"),
        "Driving_experience": data.get("Driving_experience", "Unknown"),
        "Type_of_vehicle": data.get("Type_of_vehicle", "Unknown"),
        "Number_of_vehicles_involved": data.get("Number_of_vehicles_involved", 1),
        "Number_of_casualties": data.get("Number_of_casualties", 0)
    }

    df = pd.DataFrame([new_data])
    df.to_csv(FILE, mode='a', header=False, index=False)

    return jsonify({"status": "Data added"})

app.run(port=5000)