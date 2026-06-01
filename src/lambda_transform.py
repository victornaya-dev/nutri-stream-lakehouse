import json
import boto3
import base64

s3 = boto3.client('s3')
BUCKET = "food-facts-raw-victor"

def lambda_handler(event, context):
    for record in event['Records']:
        payload = base64.b64decode(record['kinesis']['data'])
        product = json.loads(payload)

        cleaned = {
            "product_name": product.get("product_name", "").strip() or None,
            "brands": product.get("brands", "").strip() or None,
            "categories": product.get("categories", "").strip() or None,
            "nutriscore_grade": product.get("nutriscore_grade", "").lower() or None,
            "sugars": float(product.get("nutriments", {}).get("sugars_100g") or 0),
            "fat": float(product.get("nutriments", {}).get("fat_100g") or 0),
            "salt": float(product.get("nutriments", {}).get("salt_100g") or 0),
        }

        if not cleaned["product_name"] or not cleaned["nutriscore_grade"]:
            continue

        key = f"cleaned/{record['kinesis']['sequenceNumber']}.json"
        s3.put_object(Bucket=BUCKET, Key=key, Body=json.dumps(cleaned))