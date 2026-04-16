FROM rocker/r-base

WORKDIR /app

COPY . /app

RUN Rscript -e "install.packages('tidyverse', repos='https://cloud.r-project.org')" && \
    Rscript -e "install.packages('caret', repos='https://cloud.r-project.org')" && \
    Rscript -e "install.packages('randomForest', repos='https://cloud.r-project.org')" && \
    Rscript -e "install.packages('httr', repos='https://cloud.r-project.org')" && \
    Rscript -e "install.packages('jsonlite', repos='https://cloud.r-project.org')"

CMD ["Rscript", "analysis.R"]