import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame
from pyspark.sql.functions import col, upper

args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Leer JSON desde Glue Catalog
datasource = glueContext.create_dynamic_frame.from_catalog(
    database="food_facts_db",
    table_name="cleaned"
)

# Convertir a DataFrame y transformar
df = datasource.toDF()
df = df.filter(col("product_name").isNotNull())
df = df.filter(col("nutriscore_grade").isNotNull())
df = df.withColumn("nutriscore_grade", upper(col("nutriscore_grade")))

# Escribir Parquet particionado
output = DynamicFrame.fromDF(df, glueContext, "output")
glueContext.write_dynamic_frame.from_options(
    frame=output,
    connection_type="s3",
    connection_options={
        "path": "s3://food-facts-processed-victor/parquet/",
        "partitionKeys": ["nutriscore_grade"]
    },
    format="parquet"
)

job.commit()