setwd('~/Desktop/CISC 351/CISC351 Final Project/CISC351 Project Datasets')
library(readxl)
basic_stats = read_excel('/Users/bennettfahey/Desktop/CISC 351/archiveNBA/NBA Players - Basic Season Stats (1950-2017).xlsx')
adv_stats = read_excel("/Users/bennettfahey/Desktop/CISC 351/archiveNBA/NBA Players - Advanced Season Stats (1978-2016).xlsx")


#Data cleaning - Compile datasets

# Remove empty/unnecessary columns
basic_sub = as.data.frame(basic_stats[, -c(1, 23, 28)])
adv_sub = as.data.frame(adv_stats[, -c(2, 9, 19, 24, 32, 35)])
# Rename columns in basic_sub for arrange() and filter()
colnames(basic_sub)[1] = 'Year'
colnames(basic_sub)[2] = 'Player'
colnames(basic_sub)[3] = 'Salary'
# Create consistent ordering for both datasets
library(tidyverse)
basic = filter(arrange(basic_sub, Year, Player), Year < 2016 & Year > 1989)
adv = filter(arrange(adv_sub, year, player), year < 2016 & year > 1989)
# Remove observations that split a player's season stats before and after a trade has occurred
index = rep(TRUE, nrow(basic))
for (i in 1:(nrow(basic) - 1)) {
  if (basic$Year[i] == basic$Year[i + 1] &  basic$Player[i] == basic$Player[i + 1]) {
    index[i + 1] = FALSE
  }
}
basic2 = basic[index,]
index2 = rep(TRUE, nrow(adv))
for (i in 1:(nrow(adv) - 1)) {
  if (adv$year[i] == adv$year[i + 1] &  adv$player[i] == adv$player[i + 1]) {
    index2[i + 1] = FALSE
  }
}
adv2 = adv[index2,]
# Final observations with matching names
basic2[-c(6764, 8726, 8730, 8745, 9644, 10028), ]
adv2[-c(8604, 8786, 9046), ]


#Data Cleaning - Remove recurrent columns and observations without recorded salary

# Prune redundant covariates from basic data
basic = basic2[-c(6764, 8726, 8730, 8745, 9644, 10028), c(1:5, 7:29, 32, 35, 38, 39, 42:44, 46:51)]
# Prune redundant covariates from advanced data
advanced = adv2[-c(8604, 8786, 9046), c(23, 31, 33, 35:37, 39, 85, 86, 88)]
data = cbind(basic, advanced)  ## Join data sets
data = data[!is.na(data$Salary),]  ## Remove observations without salary


#Finding mean salary in each
data90 = filter(data, Year == 1990)
data15 = filter(data, Year == 2015)
mean(data90$Salary)
#906687.1
mean(data15$Salary, na.rm = TRUE)
#5414411



#Feature Engineering - Adjust points, rebounds, assists, blocks to per game metric and salary to percentage

# Import salary cap data
setwd('~/Desktop/CISC 351/CISC351 Final Project/CISC351 Project Datasets')
salary_cap = read.csv('/Users/bennettfahey/Desktop/CISC 351/sportsref_download.csv')[, -3]

salary_cap$Salay.Cap = as.numeric(gsub("[$,]", "", as.character(salary_cap$Salay.Cap)))
salary_cap$Year = substring(salary_cap$Year,1,4)
salary_cap$Year


# Convert salary feature to percentage of total salary cap and standardize remaining features
for (i in 1:nrow(data)) {
  data$Salary[i] = data$Salary[i] / salary_cap[salary_cap$Year == data$Year[i], 2]
  data$PTS[i] = data$PTS[i] / data$G[i]
  data$AST[i] = data$AST[i] / data$G[i]
  data$STL[i] = data$STL[i] / data$G[i]
  data$DRB[i] = data$DRB[i] / data$G[i]
  data$ORB[i] = data$ORB[i] / data$G[i]
  data$BLK[i] = data$BLK[i] / data$G[i]
  data$TOV[i] = data$TOV[i] / data$G[i]
  data$PF[i] = data$PF[i] / data$G[i]
  data$MP[i] = data$MP[i] / data$G[i]
  if (is.na(data$`3P%`[i])) {
    data$`3P%`[i] = 0
  }
  if (is.na(data$`FT%`[i])) {
    data$`FT%`[i] = 0
  }
}
# Position as factor
data$Pos = as.factor(data$Pos)
# Remove observations with missing values
na = rep(0, ncol(data))
for (i in 1:ncol(data)) {
  na[i] = sum(is.na(data[, i]))
}
data = na.omit(data)

#Correlation
install.packages("corrplot")
source("http://www.sthda.com/upload/rquery_cormat.r")
library(corrplot)
cordat = data[3]
rquery.cormat(data)

head(data)
view(data)

nums = unlist(lapply(data, is.numeric))
num_data = data[,nums]



mat = cor(num_data)

df = as.data.frame(mat)


install.packages("gcookbook")
library(ggplot2)
library(tidyverse)

#Creating correlation graphic
df %>% 
  arrange(Salary) %>% 
  ggplot(df2, mapping = aes( y = row.names(df2), x = Salary)) +
  geom_col(fill = "blue" ,color = "red")+
  theme(axis.text.x = element_text(angle = 90, hjust=1)) + # rotate the labels 
  labs(y = "Statistic", x = "Correlation with salary")



corrplot(cor(num_data), tl.cex = 0.5)

#Exploratory analysis
cor.test(data$Salary, data$'STL%')
cor.test(data$Salary, data$Age)


#Constructing train and test sets
set.seed(1)
train_index = sample(nrow(data), round(nrow(data) * 0.8))
train = data[train_index, ]
val = data[-train_index, ]
