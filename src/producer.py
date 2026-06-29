import boto3
import json
import random
import time
import requests

# ── Config ───────────────────────────────────────────────────────────────────
STREAM_NAME = "food-facts-stream"
REGION      = "eu-west-1"
PAGE_SIZE   = 10
SLEEP_SEC   = 30

URL = "https://fr.openfoodfacts.org/api/v2/search"

session = requests.Session()
session.headers.update({
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
    "Accept": "application/json",
    "Accept-Language": "fr-FR,fr;q=0.9",
})

kinesis = boto3.client("kinesis", region_name=REGION)

# ── Fetch products (retry on 401/503 with a different page) ──────────────────
def get_products(max_retries=5):
    for attempt in range(max_retries):
        params = {
            "fields":    "id,product_name,brands,categories,nutriments,nutriscore_grade",
            "page_size": PAGE_SIZE,
            "page":      random.randint(1, 50),
        }
        try:
            response = session.get(URL, params=params, timeout=30)
            if response.status_code in (401, 503):
                print(f"[WARN] {response.status_code} on page {params['page']}, trying another page...")
                time.sleep(2)
                continue
            response.raise_for_status()
            return response.json().get("products", [])
        except requests.exceptions.RequestException as e:
            print(f"[ERROR] Request failed: {e}")
            time.sleep(2)
    return []

# ── Send to Kinesis ───────────────────────────────────────────────────────────
def send_to_kinesis(product):
    kinesis.put_record(
        StreamName=STREAM_NAME,
        Data=json.dumps(product),
        PartitionKey=str(product.get("id", "default"))
    )

# ── Main loop ─────────────────────────────────────────────────────────────────
def main():
    print(f"Starting producer → stream: {STREAM_NAME}")
    total = 0

    while True:
        products = get_products()

        if not products:
            print(f"[WARN] No products after retries. Waiting {SLEEP_SEC}s...")
            time.sleep(SLEEP_SEC)
            continue

        sent = 0
        for product in products:
            name = product.get("product_name", "").strip()
            if not name:
                continue
            send_to_kinesis(product)
            print(f"Enviado: {name}")
            sent += 1

        total += sent
        print(f"{sent} productos enviados (total: {total}). Esperando {SLEEP_SEC}s...\n")
        time.sleep(SLEEP_SEC)

if __name__ == "__main__":
    main()