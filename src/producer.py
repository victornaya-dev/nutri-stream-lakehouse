import boto3
import requests
import json
import time
import random


kinesis = boto3.client('kinesis', region_name='eu-west-1')

def get_products():
    url = "https://world.openfoodfacts.org/api/v2/search"
    headers = {
        "User-Agent": "nutri-stream-lakehouse/1.0 (victor@example.com)"
    }
    params = {
        "countries_tags": "france",
        "fields": "id,product_name,brands,categories,nutriments,nutriscore_grade",
        "page_size": 10,
        "page": random.randint(1, 1000)
    }
    try:
        response = requests.get(url, params=params, headers=headers, timeout=30)
        print(f"Status: {response.status_code}")
        if response.status_code != 200 or not response.text:
            print("Error en la API")
            return []
        return response.json().get("products", [])
    except requests.exceptions.RequestException as e:
        print(f"Error de conexión: {e}")
        return []


def send_to_kinesis(product):
    kinesis.put_record(
        StreamName="food-facts-stream",
        Data=json.dumps(product),
        PartitionKey=str(product.get("id", "default"))
    )
    print(f"Enviado: {product.get('product_name', 'unknown')}")

if __name__ == "__main__":
    while True:
        print("Obteniendo productos...")
        products = get_products()
        for product in products:
            send_to_kinesis(product)
        print(f"{len(products)} productos enviados. Esperando 30s...")
        time.sleep(30)

