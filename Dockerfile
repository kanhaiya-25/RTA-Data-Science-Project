FROM r-base

WORKDIR /app

COPY . /app

RUN Rscript -e "install.packages(c('tidyverse','caret','randomForest','httr','jsonlite','ggplot2','dplyr'))"

CMD ["Rscript", "analysis.R"]