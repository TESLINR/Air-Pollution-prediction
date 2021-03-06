# Libraries
library(keras)
library(mlbench) 
library(dplyr)
library(magrittr)
library(neuralnet)
library(tensorflow)

# Data
air <- read.csv(file = "orginal.csv")
#air <- air[,5:10]
air$PM25 <- as.numeric(air$PM25)
str(air)

data %<>% mutate_if(is.factor, as.numeric)

# Neural Network Visualization
n <- neuralnet(PM25 ~ Temperature+Humidity+Wind.Speed..km.h.+Visibility+Pressure+so2+no2+Rainfall+PM10,
               data = air,
               hidden = c(10,5,2),
               linear.output = F,
               lifesign = 'full',
               rep=1,)
plot(n,
     col.hidden = 'darkgreen',
     col.hidden.synapse = 'darkgreen',
     show.weights = T,
     information = T,
     fill = 'lightblue')

# Matrix
air <- as.matrix(air)
dimnames(air) <- NULL

# Partition
set.seed(1234)
ind <- sample(2, nrow(air), replace = T, prob = c(.7, .3))
training <- air[ind==1,1:5]
test <- air[ind==2, 1:5]
trainingtarget <- air[ind==1, 6]
testtarget <- air[ind==2, 6]

# Normalize
m <- colMeans(training)
s <- apply(training, 2, sd)
training <- scale(training, center = m, scale = s)
test <- scale(test, center = m, scale = s)

# Create Model
model <- keras_model_sequential()
model %>% 
  layer_dense(units = 5, activation = 'relu', input_shape = c(5)) %>%
  layer_dense(units = 1,)

install_tensorflow()
# Compile
model %>% compile(loss = 'mse',
                  optimizer = 'rmsprop',
                  metrics = 'mae')
# Fit Model
mymodel <- model %>%
  fit(training,
      trainingtarget,
      epochs = 100,
      batch_size = 32,
      validation_split = 0.2)

# Evaluate
model %>% evaluate(test, testtarget)
pred <- model %>% predict(test)
mean((testtarget-pred)^2)
plot(testtarget, pred)


# finemodel
model <- keras_model_sequential()
model %>% 
  layer_dense(units = 10, activation = 'relu', input_shape = c(9)) %>%
  layer_dense(units = 5, activation = 'relu') %>%
  layer_dense(units = 1,)

# Compile
model %>% compile(loss = 'mse',
                  optimizer = 'rmsprop',
                  metrics = 'mae')

# Fit Model
mymodel <- model %>%
  fit(training,
      trainingtarget,
      epochs = 100,
      batch_size = 32,
      validation_split = 0.2)

# Evaluate
model %>% evaluate(test, testtarget)
pred <- model %>% predict(test)
model %>% predict_classes(test)

model %>% summary(test)

mean((testtarget-pred)^2)
plot(testtarget, pred)


#ultra finetuning

model <- keras_model_sequential()
model %>% 
  layer_dense(units = 1000, activation = 'tanh', input_shape = c(9)) %>%
  layer_dropout(rate = 0.03) %>%
  layer_dense(units = 500, activation = 'tanh') %>%
  layer_dropout(rate = 0.02) %>%
  layer_dense(units = 200, activation = 'tanh') %>%
  layer_dropout(rate = 0.01) %>%
  layer_dense(units = 1,)
summary(model)
# Compile
model %>% compile(loss = 'mse',
                  optimizer = 'rmsprop',
                  metrics = 'mae')

# Fit Model
mymodel <- model %>%
  fit(training,
      trainingtarget,
      epochs = 150,
      batch_size = 35,
      validation_split = 0.2)

# Evaluate
model %>% evaluate(test, testtarget)
pred <- model %>% predict(test)
# model %>% predict_classes(test)

model %>% summary(test)

mean((testtarget-pred)^2)
plot(testtarget, pred)



 
# saveRDS(mymodel, "deepMPL1.RDS")












