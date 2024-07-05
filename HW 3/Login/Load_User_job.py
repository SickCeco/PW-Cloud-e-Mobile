import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame

# Percorso del file CSV su S3
tedx_dataset_path = "s3://user-database-tedx/User_DB.csv"

# Leggi i parametri del job
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

# Avvia il contesto Spark e il job AWS Glue
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Leggi il file CSV per creare un DataFrame
tedx_dataset = spark.read \
    .option("header", "true") \
    .option("quote", "\"") \
    .option("escape", "\"") \
    .csv(tedx_dataset_path)

# Visualizza lo schema del dataset
tedx_dataset.printSchema()

# Converti il DataFrame in un DynamicFrame
tedx_dataset_dynamic_frame = DynamicFrame.fromDF(tedx_dataset, glueContext, "nested")

# Opzioni di scrittura per MongoDB
write_mongo_options = {
    "connectionName": "TEDX2024",
    "database": "unibg_tedx_2024",
    "collection": "tedx_user",
    "ssl": "true",
    "ssl.domain_match": "false"
}

# Scrivi il DynamicFrame in MongoDB
glueContext.write_dynamic_frame.from_options(tedx_dataset_dynamic_frame, connection_type="mongodb", connection_options=write_mongo_options)

# Completa il job
job.commit()
