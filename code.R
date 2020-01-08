library(data.table)
library(dplyr)
library(ggplot2)
library(MASS)
library(rpart)


#adat beolvasasa
data <- fread('data/Liverpool_football_data.csv')

summary(data)


# megfelelo oszlopok kialakitasa a modellhez
train_data <- data.table()

for (i in 0:15){
  print(paste(formatC(3+i, width=2, flag="0"), formatC(4+i, width=2, flag="0"), sep="-"))
  season <- data[year == paste(formatC(3+i, width=2, flag="0"), formatC(4+i, width=2, flag="0"), sep="-")]
  seasonsbefore <- data[year %in% c(paste(formatC(0+i, width=2, flag="0"), formatC(1+i, width=2, flag="0"), sep="-"), 
                                    paste(formatC(1+i, width=2, flag="0"), formatC(2+i, width=2, flag="0"), sep="-"),
                                    paste(formatC(2+i, width=2, flag="0"), formatC(3+i, width=2, flag="0"), sep="-"))]
  
  team_data <- data.table(team=character(),
                          mean_goals_scored=numeric(), 
                          mean_goals_received=numeric(), 
                          mean_shots_on_target=numeric())
  
  for (l in 1:19){
    temp <- seasonsbefore[OTHER == unique(season$OTHER)[l]]
    row <- data.table(team=unique(season$OTHER)[l],
                      mean_goals_scored=mean(temp$L_goals), 
                      mean_goals_received=mean(temp$O_goals), 
                      mean_shots_on_target=mean(temp$L_shots_on_target))
    team_data <- rbindlist(list(team_data, row))
  }
  
  team_data[is.na(team_data)] <- 0
  
  
  for (l in 1:19){
    season[OTHER==unique(season$OTHER)[l], 
           mean_goals_scored:=team_data[team==unique(season$OTHER)[l], mean_goals_scored]]
    season[OTHER==unique(season$OTHER)[l], 
           mean_goals_received:=team_data[team==unique(season$OTHER)[l], mean_goals_received]]
    season[OTHER==unique(season$OTHER)[l], 
           mean_shots_on_target:=team_data[team==unique(season$OTHER)[l], mean_shots_on_target]]
  }
  
  train_data <- rbindlist(list(train_data, season))
}

train_data[, goal_difference_lag1 := lag(train_data$goal_difference, n=1)]
train_data[, goal_difference_lag2 := lag(train_data$goal_difference, n=2)]
train_data[, goal_difference_lag3 := lag(train_data$goal_difference, n=3)]
train_data[, L_shots_on_target_lag1 := lag(train_data$L_shots_on_target, n=1)]
train_data[, L_shots_on_target_lag2 := lag(train_data$L_shots_on_target, n=2)]
train_data[, L_shots_on_target_lag3 := lag(train_data$L_shots_on_target, n=3)]
train_data[, yellow_cards_lag1 := lag(train_data$L_yellow_cards, n=1)]
train_data[is.na(train_data)] <- 0

to_model <- train_data[, .(goal_difference, 
                           home, 
                           mean_goals_scored, 
                           mean_goals_received, 
                           mean_shots_on_target,
                           goal_difference_lag1,
                           goal_difference_lag2,
                           goal_difference_lag3,
                           L_shots_on_target_lag1,
                           L_shots_on_target_lag2,
                           L_shots_on_target_lag3,
                           yellow_cards_lag1)]


# test_data letrehozasa
season <- data[year == "19-20"]
seasonsbefore <- data[year %in% c("16-17", "17-18", "18-19")]

team_data <- data.table(team=character(),
                        mean_goals_scored=numeric(), 
                        mean_goals_received=numeric(), 
                        mean_shots_on_target=numeric())

for (l in 1:19){
  temp <- seasonsbefore[OTHER == unique(season$OTHER)[l]]
  row <- data.table(team=unique(season$OTHER)[l],
                    mean_goals_scored=mean(temp$L_goals), 
                    mean_goals_received=mean(temp$O_goals), 
                    mean_shots_on_target=mean(temp$L_shots_on_target))
  team_data <- rbindlist(list(team_data, row))
}

team_data[is.na(team_data)] <- 0


for (l in 1:19){
  season[OTHER==unique(season$OTHER)[l], 
         mean_goals_scored:=team_data[team==unique(season$OTHER)[l], mean_goals_scored]]
  season[OTHER==unique(season$OTHER)[l], 
         mean_goals_received:=team_data[team==unique(season$OTHER)[l], mean_goals_received]]
  season[OTHER==unique(season$OTHER)[l], 
         mean_shots_on_target:=team_data[team==unique(season$OTHER)[l], mean_shots_on_target]]
}

test_data <- season

test_data[, goal_difference_lag1 := lag(test_data$goal_difference, n=1)]
test_data[, goal_difference_lag2 := lag(test_data$goal_difference, n=2)]
test_data[, goal_difference_lag3 := lag(test_data$goal_difference, n=3)]
test_data[, L_shots_on_target_lag1 := lag(test_data$L_shots_on_target, n=1)]
test_data[, L_shots_on_target_lag2 := lag(test_data$L_shots_on_target, n=2)]
test_data[, L_shots_on_target_lag3 := lag(test_data$L_shots_on_target, n=3)]
test_data[, yellow_cards_lag1 := lag(test_data$L_yellow_cards, n=1)]
test_data[is.na(test_data)] <- 0

to_model_test <- test_data[, .(goal_difference, 
                               home, 
                               mean_goals_scored, 
                               mean_goals_received, 
                               mean_shots_on_target,
                               goal_difference_lag1,
                               goal_difference_lag2,
                               goal_difference_lag3,
                               L_shots_on_target_lag1,
                               L_shots_on_target_lag2,
                               L_shots_on_target_lag3,
                               yellow_cards_lag1)]


#a valtozok vizsgalata
ggplot(data=train_data, aes(goal_difference)) + geom_histogram()

ggplot(data=train_data, aes(goal_difference)) + geom_histogram() + 
  facet_wrap(~ as.factor(home))

train_data[, mean(goal_difference), by=home]


#regresszios modell
lm_full <- lm(goal_difference ~ ., data=to_model)
step <- stepAIC(lm_full, trace=FALSE)

summary(step)

lm_pred <- predict(step, to_model_test)


#PCA modell
pca <- prcomp(to_model, scale = TRUE)

std_dev <- pca$sdev
pr_var <- std_dev^2
prop_varex <- pr_var/sum(pr_var)

plot(cumsum(prop_varex), xlab = "Principal Component",
     ylab = "Cumulative Proportion of Variance Explained",
     type = "b")

train.data <- data.frame(goal_difference = to_model$goal_difference, pca$x)
rpart.model <- rpart(goal_difference ~ .,data = train.data, method = "anova")




test.data <- predict(pca, newdata = to_model_test)
test.data <- as.data.frame(test.data)

rpart.prediction <- predict(rpart.model, test.data)
pca_pred <- rpart.prediction


#az eredmenyek abrazolasa
results <- data.table(goal_difference=to_model_test$goal_difference,
                      lm_prediction=lm_pred,
                      pca_prediction=pca_pred)
results[, match := as.integer(row.names(results))]


ggplot(data=results, aes(x=match)) +
  geom_line(aes(y=goal_difference, color="obs")) +
  geom_line(aes(y=lm_prediction, color="LM")) +
  geom_line(aes(y=pca_prediction, color="PCA"))