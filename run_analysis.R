library(reshape2)

filename <- "getdata_dataset.zip"

## Download and unzip the dataset:
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("HARData")) { 
  unzip(filename) 
}

# Load labels + features
Labels <- read.table("HARData/activity_labels.txt")
Labels[,2] <- as.character(Labels[,2])
# Load features
features <- read.table("HARData/features.txt")
features[,2] <- as.character(features[,2])

# Extract metrics 
featuresSelected <- grep(".*mean.*|.*std.*", features[,2])
featuresSelected.names <- features[featuresSelected,2]
featuresSelected.names = gsub('-mean', 'Mean', featuresSelected.names)
featuresSelected.names = gsub('-std', 'Std', featuresSelected.names)
featuresSelected.names <- gsub('[-()]', '', featuresSelected.names)


# Load the datasets
train <- read.table("HARData/train/X_train.txt")[featuresSelected]
trainActivities <- read.table("HARData/train/Y_train.txt")
trainSubjects <- read.table("HARData/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("HARData/test/X_test.txt")[featuresSelected]
testActivities <- read.table("HARData/test/Y_test.txt")
testSubjects <- read.table("HARData/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge datasets + labels
fullData <- rbind(train, test)
colnames(fullData) <- c("subject", "activity", featuresSelected.names)

# turn activities & subjects into factors
fullData$activity <- factor(fullData$activity, levels = Labels[,1], labels = Labels[,2])
fullData$subject <- as.factor(fullData$subject)

fullData.melted <- melt(fullData, id = c("subject", "activity"))
fullData.mean <- dcast(fullData.melted, subject + activity ~ variable, mean)

write.table(fullData.mean, "tidyData.txt", row.names = FALSE, quote = FALSE)