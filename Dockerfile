FROM jupyter/pyspark-notebook:latest

USER root

# Install additional Python packages
RUN pip install --no-cache-dir \
    pymongo==4.6.0 \
    requests==2.31.0 \
    pandas==2.1.3 \
    numpy==1.24.3

# Switch back to jovyan user
USER jovyan

EXPOSE 8888
