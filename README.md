# Docker Compose: Jupyter + MongoDB + PySpark

A complete Docker Compose setup for:
- **Jupyter Lab** - Interactive notebook environment
- **MongoDB** - NoSQL database
- **Apache Spark** - Distributed data processing

## Quick Start

### Prerequisites
- Docker & Docker Compose installed

### Run

```bash
docker-compose up --build
```

### Access Services

- **Jupyter Lab**: http://localhost:8888
- **Spark Master UI**: http://localhost:8080
- **MongoDB**: localhost:27017 (connection string: `mongodb://root:password@mongodb:27017`)

## Workflow

1. Open Jupyter Lab in your browser
2. Open the example notebook (`example.ipynb`)
3. Download a text file from the internet
4. Insert the content into MongoDB
5. Read the data with PySpark
6. Perform analytics and transformations

## Example Notebook

See `notebooks/example.ipynb` for a complete example that shows:
- Fetching a text file from a URL
- Storing it in MongoDB
- Reading with PySpark
- Performing word count analysis

## MongoDB Connection

In your Jupyter notebook:

```python
from pymongo import MongoClient

client = MongoClient('mongodb://root:password@mongodb:27017/')
db = client['mydb']
collection = db['mycollection']
```

## PySpark with MongoDB

Use the `mongo-spark-connector` library (already included) to read data:

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("MongoDBRead") \
    .master("spark://spark-master:7077") \
    .getOrCreate()

df = spark.read.format("mongo").load()
```

## Cleanup

```bash
docker-compose down -v  # -v removes volumes (database data)
```
