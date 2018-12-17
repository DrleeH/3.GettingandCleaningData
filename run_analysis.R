##library necessary package
if (!require('tidyverse')) install.packages('tidyverse')
if (!require('data.table')) install.packages('data.table')
if (!require('plyr')) install.packages('plyr')
library(tidyverse)
library(data.table)
library(plyr)
###read data
feature <- fread("features.txt")
dat <- lapply(list(train = "./train/*.txt", test = "./test/*.txt"), function(x){
  file <- Sys.glob(x)
  file_data <- lapply(file, fread)
  names(file_data[[1]]) <- feature$V2
  file_data[[1]]$activity <- file_data[[3]]$V1
  file_data[[1]]$subjectID <- file_data[[2]]$V1
  return(file_data[[1]])
})

### combine files into one dataset
comb_data <- rbind(dat[[1]], dat[[2]])


##STEP 2: Extracts only the measurements on the mean and standard
comb_data <- as.data.frame(comb_data)
dat2 <- comb_data[,str_detect(names(comb_data), "mean()|std()|activity|subjectID")]

## STEP 3: Uses descriptive activity names to name the activities in the data set.
## STEP 4: Appropriately labels the data set with descriptive activity names. 
activ <- fread("activity_labels.txt")
dat2$activity<- factor(dat2$activity, labels = dput(activ$V2))


## STEP 5: Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
tidydata<- ddply(dat2, c("subjectID","activity"), colwise(mean))

write.table(tidydata, "tidydata.txt", row.names = F)
