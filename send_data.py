import requests

url = "https://tetrandrous-malinda-trochoidally.ngrok-free.dev/add"

data = {
    "Educational_level": "High School",
    "Driving_experience": "5-10yr",
    "Type_of_vehicle": "Car",
    "Number_of_vehicles_involved": 2,
    "Number_of_casualties": 1
}

response = requests.post(url, json=data)

print(response.json())