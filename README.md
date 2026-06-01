# nutri-stream-lakehouse

> Real-time food data pipeline built on AWS — ingesting, transforming, and analyzing French food products from Open Food Facts.

![Status](https://img.shields.io/badge/status-in%20progress-yellow)
![AWS](https://img.shields.io/badge/AWS-Kinesis%20%7C%20Glue%20%7C%20Athena-orange?logo=amazon-aws)
![IaC](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform)
![Python](https://img.shields.io/badge/Python-3.11-blue?logo=python)

---

## Architecture

```
Open Food Facts API (🇫🇷)
    → Kinesis Data Streams        (real-time streaming)
    → Lambda                      (stream transformation)
    → Kinesis Firehose → S3 raw   (data lake ingestion)
    → Glue Crawler + ETL          (batch transformation)
    → S3 processed (Parquet)      (optimized storage)
    → Athena                      (SQL queries)
    → QuickSight                  (dashboard)
    → CloudWatch                  (monitoring & alerts)
```

>  Architecture diagram coming in Week 4

---

##  Stack

| Layer | Service |
|---|---|
| Streaming | AWS Kinesis Data Streams |
| Delivery | AWS Kinesis Firehose |
| Transformation | AWS Lambda (Python) + AWS Glue (PySpark) |
| Storage | AWS S3 (raw + processed) |
| Query | AWS Athena |
| Visualization | AWS QuickSight |
| Monitoring | AWS CloudWatch |
| IaC | Terraform |

---

## 📁 Project Structure

```
nutri-stream-lakehouse/
├── terraform/
│   ├── provider.tf
│   ├── s3.tf
│   ├── kinesis.tf
│   ├── lambda.tf
│   ├── glue.tf
│   ├── athena.tf
│   ├── iam_roles.tf
│   ├── variables.tf
│   └── outputs.tf
├── src/
│   ├── producer.py          # Kinesis producer — Open Food Facts API
│   ├── lambda_transform.py  # Stream transformation
│   └── glue_job.py          # Batch ETL — PySpark
├── docs/
│   └── architecture.png
└── README.md
```

---

##  Getting Started

### Prerequisites

- AWS account with billing alarm configured
- AWS CLI installed and configured (`aws configure`)
- Terraform >= 1.6
- Python >= 3.11

## Configuration

Create a `terraform/terraform.tfvars` file with your own values (never commit this file):

```hcl
kinesis_stream_arn = "arn:aws:kinesis:eu-west-1:YOUR_ACCOUNT_ID:stream/food-facts-stream"
```

This file is ignored by git — see `.gitignore`.


### Deploy infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### Run the producer

```bash
pip install boto3 requests
python src/producer.py
```

---

## Dashboard

QuickSight dashboard showing:
- Top 10 brands ingested in real time
- Product distribution by category (dairy, beverages, snacks...)
- Average sugar/fat/salt levels by category
- Nutri-Score A vs E distribution

>  Screenshots coming in Week 4

---

## Build Log

| Week | Focus | Status |
|---|---|---|
| Week 1 | S3 + Kinesis + Python producer | ✅ Done |
| Week 2 | Lambda (JSON normalize) + Firehose → S3 | 🔄 In progress |
| Week 3 | Glue ETL → Parquet + Athena queries | ⏳ Pending |
| Week 4 | QuickSight + CloudWatch + docs | ⏳ Pending |

---

## Related Article

*"Building a real-time food data pipeline with AWS Kinesis, Glue and Terraform"*
→ Published on Medium *(coming soon)*

---

##  Author

**Victor Naya** —
[![GitHub](https://img.shields.io/badge/GitHub-victornaya--dev-black?logo=github)](https://github.com/victornaya-dev)

Built as a portfolio project for the AWS Certified Data Engineer Associate (DEA-C01).

---

## License

MIT
