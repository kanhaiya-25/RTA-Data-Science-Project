library(tidyverse)
library(ggplot2)
library(dplyr)
library(caret)
library(randomForest)
library(httr)
library(jsonlite)
library(rvest)
df <- read.csv("RTA Dataset.csv", stringsAsFactors = FALSE)
str(df)
summary(df)
colSums(is.na(df))
df <- na.omit(df)
df$Day_of_week <- as.factor(df$Day_of_week)
df$Accident_severity <- as.factor(df$Accident_severity)
df$Hour <- as.numeric(substr(df$Time,1,2))
df$is_weekend <- ifelse(df$Day_of_week %in% c("Saturday","Sunday"),1,0)
ggplot(df, aes(x=Accident_severity)) + 
  geom_bar(fill="blue") +
  ggtitle("Accident Severity Distribution")
ggplot(df, aes(x=Day_of_week)) + 
  geom_bar(fill="orange")
ggplot(df, aes(x=Hour)) + 
  geom_histogram(binwidth=1, fill="red")
ggplot(df, aes(x=Weather_conditions, fill=Accident_severity)) +
  geom_bar(position="dodge")
ggplot(df, aes(x=Cause_of_accident)) +
  geom_bar() +
  theme(axis.text.x = element_text(angle=90))


url <- "https://api.openweathermap.org/data/2.5/weather?q=Chennai&appid=API_KEY"
res <- GET(url)
data <- fromJSON(rawToChar(res$content))
temp <- data$main$temp
humidity <- data$main$humidity
weather <- data$weather[[1]]$description
df$temperature <- temp
df$humidity <- humidity
set.seed(123)
trainIndex <- createDataPartition(df$Accident_severity, p=0.8, list=FALSE)
train <- df[trainIndex,]
test <- df[-trainIndex,]
model <- randomForest(Accident_severity ~ ., data=train)
pred <- predict(model, test)
colSums(is.na(train))
train <- train[!is.na(train$Hour), ]
test  <- test[!is.na(test$Hour), ]
model <- randomForest(Accident_severity ~ ., data=train)
pred <- predict(model, test)
confusionMatrix(pred, test$Accident_severity)
library(caret)

train_balanced <- upSample(
  x = train[, -which(names(train) == "Accident_severity")],
  y = train$Accident_severity
)

colnames(train_balanced)[ncol(train_balanced)] <- "Accident_severity"
model <- randomForest(Accident_severity ~ ., data=train_balanced)
pred <- predict(model, test)
confusionMatrix(pred, test$Accident_severity)
install.packages("ROSE")
library(caret)
train_balanced <- upSample(train[,-target], train$target)

class_weights <- c(
  "Fatal injury" = 10,
  "Serious Injury" = 5,
  "Slight Injury" = 1
)
model <- randomForest(
  Accident_severity ~ ., 
  data = train,
  classwt = class_weights
)
pred <- predict(model, test)
confusionMatrix(pred, test$Accident_severity)
train$Severity_binary <- ifelse(
  train$Accident_severity == "Slight Injury", 
  "Slight", 
  "Severe"
)

test$Severity_binary <- ifelse(
  test$Accident_severity == "Slight Injury", 
  "Slight", 
  "Severe"
)

train$Severity_binary <- as.factor(train$Severity_binary)
test$Severity_binary <- as.factor(test$Severity_binary)
model <- randomForest(Severity_binary ~ . -Accident_severity, data=train)
pred <- predict(model, test)
confusionMatrix(pred, test$Severity_binary)
drop_cols <- c(
  "Time",
  "Vehicle_driver_relation",
  "Work_of_casuality",
  "Fitness_of_casuality"
)

train2 <- train[, !(names(train) %in% drop_cols)]
test2  <- test[, !(names(test) %in% drop_cols)]
train2[] <- lapply(train2, function(x) if(is.character(x)) as.factor(x) else x)
test2[]  <- lapply(test2, function(x) if(is.character(x)) as.factor(x) else x)
model <- glm(Severity_binary ~ . -Accident_severity, 
             data=train2, 
             family="binomial")
prob <- predict(model, test2, type="response")
pred <- ifelse(prob > 0.2, "Severe", "Slight")
pred <- as.factor(pred)
confusionMatrix(pred, test2$Severity_binary)
thresholds <- seq(0.1, 0.9, by=0.1)

for(t in thresholds){
  pred <- ifelse(prob > t, "Severe", "Slight")
  pred <- as.factor(pred)
  
  cm <- confusionMatrix(pred, test2$Severity_binary)
  
  cat("\nThreshold:", t, "\n")
  print(cm$byClass[c("Sensitivity","Specificity")])
}
write.csv(df, "cleaned_RTA_dataset.csv", row.names = FALSE)
