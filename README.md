# ClinVar Big Data Pipeline

A containerized big data pipeline that ingests NCBI ClinVar genetic variant data into MongoDB, processes it with Apache Spark, and trains a Random Forest classifier to predict clinical significance.

## Stack

| Component | Version |
|-----------|---------|
| Jupyter Lab (PySpark) | spark-3.5.0 |
| Apache Spark | 3.5.0 |
| MongoDB | latest |
| pymongo | 4.6.0 |

## Quick Start

**Prerequisites:** [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows / macOS / Linux)

### Windows (PowerShell or Command Prompt)

```powershell
git clone <repo-url>
cd docker-jupyter-mongodb-pyspark
docker compose up --build
```

### macOS / Linux

```bash
git clone <repo-url>
cd docker-jupyter-mongodb-pyspark
docker compose up --build
```

Then open Jupyter at: **http://localhost:8888/lab?token=bigdata**

No log digging — the token is fixed.

## Services

| Service | URL |
|---------|-----|
| Jupyter Lab | http://localhost:8888/lab?token=bigdata |
| Spark Master UI | http://localhost:8080 |
| Spark Worker UI | http://localhost:8081 |
| MongoDB | localhost:27017 |

MongoDB credentials: `root` / `password`

## Stopping the Stack

```bash
# Stop containers (keeps data)
docker compose down

# Stop and delete all data (clean slate)
docker compose down -v
```

## Project Structure

```
.
├── docker-compose.yml       # Service orchestration
├── Dockerfile               # Jupyter image (adds pymongo)
├── BigDataPhase2.ipynb      # Full pipeline notebook
└── notebooks/               # Mounted into Jupyter container
```

## Pipeline Overview

The notebook `BigDataPhase2.ipynb` implements a three-phase pipeline on the [ClinVar variant_summary dataset](https://ftp.ncbi.nlm.nih.gov/pub/clinvar/tab_delimited/).

### Phase 1 — MongoDB Ingestion & Exploration
- Streams the gzipped TSV into MongoDB in batches of 5,000 documents (no pandas)
- PyMongo aggregation queries: total variant count, type distribution, variants per chromosome

### Phase 2 — PySpark ETL & Analysis
- Reads MongoDB into Spark via the MongoDB Spark Connector
- Cleans and transforms: null handling, assembly filter (GRCh37), ClinicalSignificance normalization, `variant_length` and `review_score` derived columns
- Joins with `submission_summary.txt.gz` for per-variant submission stats
- SparkSQL analysis: top pathogenic genes, variant type breakdown, conflict resolution rates by gene, disease pathogenic proportions

### Phase 3 — Machine Learning (MLlib)
- Random Forest classifier: predicts Pathogenic (1) vs Benign (0)
- Features: `review_score`, `variant_length`, `NumberSubmitters`, submission counts, gene-level pathogenic counts, encoded `Type` and `Chromosome`
- Hyperparameter tuning via `CrossValidator` + `ParamGridBuilder` (maxDepth ∈ {5, 10}, numTrees ∈ {20, 50}, 3-fold CV)
- Evaluation: AUC-ROC, Accuracy, Precision, Recall, F1, confusion matrix, feature importances

## Dataset

The notebook downloads these automatically via `!wget`. If you prefer to download manually first:

**Windows (PowerShell):**
```powershell
Invoke-WebRequest -Uri "https://ftp.ncbi.nlm.nih.gov/pub/clinvar/tab_delimited/variant_summary.txt.gz" -OutFile "variant_summary.txt.gz"
Invoke-WebRequest -Uri "https://ftp.ncbi.nlm.nih.gov/pub/clinvar/tab_delimited/submission_summary.txt.gz" -OutFile "submission_summary.txt.gz"
```

**macOS / Linux:**
```bash
wget https://ftp.ncbi.nlm.nih.gov/pub/clinvar/tab_delimited/variant_summary.txt.gz
wget https://ftp.ncbi.nlm.nih.gov/pub/clinvar/tab_delimited/submission_summary.txt.gz
```

Files are ~420 MB and ~360 MB respectively. Run from inside the `notebooks/` folder so Spark can find them.

## Troubleshooting

**Spark jobs running out of memory**  
Increase `SPARK_WORKER_MEMORY` in `docker-compose.yml` and raise the memory limit in Docker Desktop: Settings → Resources → Memory.

**SparkSession can't connect to MongoDB**  
The Spark session connects via the host bridge IP (`172.20.240.1` on Linux/Mac, may differ on Windows). If `df = spark.read...` fails, find your bridge IP:
```bash
# Linux / macOS
docker network inspect docker-jupyter-mongodb-pyspark_spark-network --format '{{range .IPAM.Config}}{{.Gateway}}{{end}}'

# Windows (PowerShell)
docker network inspect docker-jupyter-mongodb-pyspark_spark-network --format "{{range .IPAM.Config}}{{.Gateway}}{{end}}"
```
Then update the `connection.uri` in the notebook to match.

**MongoDB not ready when notebook starts**  
Run the ingestion cell again — MongoDB needs a few seconds to initialize on first start.

**"Port already in use" error**  
Another service is using 8888, 8080, 8081, or 27017. Change the host-side port in `docker-compose.yml` (e.g. `"9999:8888"`) and update the Jupyter URL accordingly.
