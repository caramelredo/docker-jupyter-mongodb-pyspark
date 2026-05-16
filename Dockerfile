FROM jupyter/pyspark-notebook:spark-3.5.0

USER root

# Install additional Python packages
RUN pip install --no-cache-dir \
    pymongo==4.6.0 \
    requests==2.31.0

# Switch back to jovyan user
USER jovyan

EXPOSE 8888
