# Docker Compose: Jupyter + MongoDB + PySpark

A complete Docker Compose setup for:
- **Jupyter Lab** - Interactive notebook environment
- **MongoDB** - NoSQL database
- **Apache Spark** - Distributed data processing

## What to do:

- download/pull repo into a folder
- right click on folder and open terminal
- enter "docker-compose up"
- enter "docker compose logs jupyter | Select-String "token"" to get jupyter notebook link

- that should be it.
- if you run into an error in the cell that reads the mongoDB into pyspark or the SparkSession cell, try messing with the configs. AI helps alot here.
