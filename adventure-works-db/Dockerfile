FROM postgres:16

# Instala dependencias y limpia
RUN apt-get update && \
    apt-get install -y --no-install-recommends unzip ruby dos2unix && \
    rm -rf /var/lib/apt/lists/*

# Carpeta de trabajo
WORKDIR /data

# Copiar archivos fuente
COPY 01_install.sql /data/
COPY update_csvs.rb /data/
COPY adventure_works_2014_OLTP_script.zip /data/

# Descomprimir y procesar CSVs
RUN unzip -q adventure_works_2014_OLTP_script.zip -d /data && \
    rm adventure_works_2014_OLTP_script.zip && \
    ruby update_csvs.rb && \
    rm update_csvs.rb

# Script de inicialización de Postgres
COPY 00_run_install.sh /docker-entrypoint-initdb.d/
RUN dos2unix /docker-entrypoint-initdb.d/*.sh && chmod +x /docker-entrypoint-initdb.d/*.sh
