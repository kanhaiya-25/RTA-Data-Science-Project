FROM rocker/r-base

WORKDIR /app

COPY . /app

RUN Rscript -e "install.packages(c('tidyverse','caret','randomForest','httr','jsonlite','ggplot2','dplyr'), repos='https://cloud.r-project.org')"

CMD ["Rscript", "analysis.R"]