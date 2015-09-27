## Load libraries
library(dplyr)
library(reshape2)

## Read the feature information in a dataframe
features <- read.csv("./UCI HAR Dataset/features.txt", header = FALSE, sep = " ", col.names = c("id", "feature"))

## Read the files into different data frames
test_x <- read.csv("./UCI HAR Dataset/test/X_test.txt", header = FALSE, sep = "", col.names = features$feature)
train_x <- read.csv("./UCI HAR Dataset/train/X_train.txt", header = FALSE, sep = "", col.names = features$feature)

## Extract measurements on the mean and standard deviation
test_x <- select(test_x, contains("mean"), contains("std"))
train_x <- select(train_x, contains("mean"), contains("std"))

## Read the activity files into data frames
train_y <- read.csv("./UCI HAR Dataset/train/y_train.txt", header = FALSE, col.names = "activity")
test_y <- read.csv("./UCI HAR Dataset/test/y_test.txt", header = FALSE, col.names = "activity")

## Read the volunteer files into data frames
test_subject <- read.csv("./UCI HAR Dataset/test/subject_test.txt", header = FALSE, col.names = "volunteer")
train_subject <- read.csv("./UCI HAR Dataset/train/subject_train.txt", header = FALSE, col.names = "volunteer")

## Combine the 3 files for test and train and make them tbl data frames, for ease of printing
test_combine <- tbl_df(cbind(test_subject, test_y, test_x))
train_combine <- tbl_df(cbind(train_subject, train_y, train_x))

## Add a variable to each set, to determine if it is a test or train result
test_combine <- mutate(test_combine, type = "test")
train_combine <- mutate(train_combine, type = "train")

## Combine the two data frames into 1 file
merged <- rbind(train_combine, test_combine)

## Replace the numeric codes under activity with the proper names
activity_names <- c("Walking", "Walking_Upstairs", "Walking_Downstairs", "Sitting", "Standing", "Laying")
merged <- mutate(merged, activity = activity_names[activity])

## Create a second independent tidy dataset with the average of each variable for each activity and each subject
## Use grep for pattern matching to find the mean and std variables
merged_grep <- merged[,c("volunteer", "activity", grep("mean|std", colnames(merged), value = TRUE))]

## Melt the data frame by volunteer and activity
merged_melt <- melt(merged_grep, id.vars = c("volunteer", "activity"))

## Dcast by volunteer and activity and calculate the mean
merged_tidy <- dcast(merged_melt, volunteer + activity ~ variable, mean)

## Write dataset to textfile
write.table(merged_tidy, file="merged_tidy.txt", row.names=FALSE)
