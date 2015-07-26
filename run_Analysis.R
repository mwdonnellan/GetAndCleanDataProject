##################################################################################
#File name:			run_analysis.R
#File contents: 	R code to fulfil the requirements of the course project
#					for the "Getting and Cleaning Data" course offered
#					on http://coursera.org
#Author:			mwd
#Date:				26 July 2015
#Purpose:			From the course assignment page at 
#					https://class.coursera.org/getdata-030/human_grading/view/courses/975114/assessments/3/submissions
#					The purpose of this project is to demonstrate ability to collect, 
#					work with, and clean a data set. The goal is to prepare tidy data that 
#					can be used for later analysis. 
#					The data set is downloadable from
#					https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
#					and a description of the experimental procedure through which these data
#					were collected is available at
#					http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones .
#					Briefly, the original data were obtained "from the recordings of 30 
#					subjects performing activities of daily living (ADL) while carrying a 
#					waist-mounted smartphone with embedded inertial sensors." 
#					Specific tasks performed by this script include:		
#						1.Merges the training and the test sets to create one data set.
#						2.Extracts only the measurements on the mean and standard deviation for each measurement. 
#						3.Uses descriptive activity names to name the activities in the data set
#						4.Appropriately labels the data set with descriptive variable names. 
#						5.From the data set in step 4, creates a second, independent tidy data 
#						 set with the average of each variable for each activity and each subject.
#Data set information: The experiments have been carried out with a group of 30 volunteers 
#					within an age bracket of 19-48 years. Each person performed six activities
#					(WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) 
#					wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded 
#					accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial 
#					angular velocity at a constant rate of 50Hz. The experiments have been 
#					video-recorded to label the data manually. The obtained dataset has been 
#					randomly partitioned into two sets, where 70% of the volunteers was selected 
#					for generating the training data and 30% the test data. 
#					The sensor signals (accelerometer and gyroscope) were pre-processed by 
#					applying noise filters and then sampled in fixed-width sliding windows 
#					of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, 
#					which has gravitational and body motion components, was separated using a Butterworth 
#					low-pass filter into body acceleration and gravity. The gravitational force is 
#					assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff 
#					frequency was used. From each window, a vector of features was obtained by calculating 
#					variables from the time and frequency domain.
##################################################################################
#
#	Step 0: download, decompress, and read the selected data
#
##################################################################################

#Start clean
rm(list = ls(all = TRUE))
unlink("*",recursive=TRUE)

#load the necessary libraries
require(plyr)
require(data.table)
require(dplyr) #will mask certain functions in other packages

#create a directory for the data file to be downloaded
dir.create("./UCIHARDataFiles")

#put the relative path into a variable
uciDataFileDir <- dir()

#get the URL into a var
dlURL <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

#get the destination path and filename into a var
dlFileName <- file.path(uciDataFileDir,basename(dlURL))

#download the data file
download.file(dlURL,dlFileName)

#decompress the data file, get the list of files into a vector for interactive inspection
#to choose files (interactive inspection not coded)
dataFileList <- unzip(dlFileName, list=TRUE)

#we choose to extract the relevant files one at a time into the respective vars
#trading multiple calls into unzip for overall tidiness
featureTable <- read.table(unzip(dlFileName, "UCI HAR Dataset/features.txt"))
xTrainData <- read.table(unzip(dlFileName, "UCI HAR Dataset/train/X_train.txt"))
yTrainData <- read.table(unzip(dlFileName, "UCI HAR Dataset/train/y_train.txt"))
subjectTrainData <- read.table(unzip(dlFileName, "UCI HAR Dataset/train/subject_train.txt"))
xTestData <- read.table(unzip(dlFileName, "UCI HAR Dataset/test/X_test.txt"))
yTestData <- read.table(unzip(dlFileName, "UCI HAR Dataset/test/y_test.txt"))
subjectTestData <- read.table(unzip(dlFileName, "UCI HAR Dataset/test/subject_test.txt"))

#clean up: we no longer need the downloaded data file
unlink(dlFileName)

##################################################################################
#
#	Step 1: put the training and test datasets back into a single dataset
#               fulfils requirement 1 of assignment
#
##################################################################################

#get x, y, and subject complete datasets
xAllData <- rbind(xTrainData, xTestData)
yAllData <- rbind(yTrainData, yTestData)
subjectAllData <- rbind(subjectTrainData, subjectTestData)

#now get the complete dataset
completeData <- cbind(subjectAllData,yAllData,xAllData)

#now free up memory by removing unneeded structures
rm(xTrainData, xTestData,subjectTestData, xTestData, yTestData, subjectTestData)

##################################################################################
#
#	Step 2: impose descriptive names on ID columns and feature names on measurement columns
#               fulfils requirement 3 in the assignment
#
##################################################################################

featureLabels <- as.character(featureTable[,2])
columnLabels <- c("Subject","Activity",featureLabels)
colnames(completeData) <- columnLabels

##################################################################################
#
#	Step 3: extract only the measurements on the mean and standard deviation for each measurement.
#               fulfils requirement 2 in the assignment
#
##################################################################################

#get the names of features for means
meanFeatures <- grep("mean()", colnames(completeData))
#get the names of features for StdDev
stdFeatures <- grep("std()", colnames(completeData))
#make these 2 lists into 1
newColumnLabels <- sort(c(meanFeatures, stdFeatures))
#stage 1 of trimming the completeData dataset: get the mean and StdDev measurements
tempDataFrame <- completeData[, c(1,2,newColumnLabels)]
#stage 2 of trimming the completeData dataset: get rid of frequency
trimmedDataFrame <- tempDataFrame[, !grepl("Freq", colnames(tempDataFrame))] #get rid of the meanFreq columns

#remove unneeded structures, cheepnis is good
#rm(tempDataFrame, completeData)

##################################################################################
#
#	Step 4: create a dataset of the overall averages for each subject|activity tuple
#               fulfils requirement 5 in the assignment
#
##################################################################################

outputDataFrame <- data.frame()
for (subjectIndex in 1:length(unique(trimmedDataFrame$Subject))) 
{
        thisSubject <- subset(trimmedDataFrame,Subject == subjectIndex)
        for (activityIndex in 1:length(unique(trimmedDataFrame$Activity)))
        {
                thisActivity <- subset(thisSubject, Activity == activityIndex)
                subjectActivityMean <- as.vector(apply(thisActivity,2,mean))
                outputDataFrame <- rbind(outputDataFrame,subjectActivityMean) 
        }
        
}

##################################################################################
#
#	Step 5: apply appropriate labels to the activities and apply the
#               measure labels.
#               fulfils requirement 4 in the assignment
#
##################################################################################

#fix the column names that we nuked in the nested loop above
colnames(outputDataFrame) <- colnames(trimmedDataFrame) 
#apply meaningful names from to the numeric labels for the 6 activities
outputDataFrame$Activity <- as.character(outputDataFrame$Activity)
outputDataFrame$Activity[outputDataFrame$Activity == 1] <- "Walking"
outputDataFrame$Activity[outputDataFrame$Activity == 2] <- "Walking Upstairs"
outputDataFrame$Activity[outputDataFrame$Activity == 3] <- "Walking Downstairs"
outputDataFrame$Activity[outputDataFrame$Activity == 4] <- "Sitting"
outputDataFrame$Activity[outputDataFrame$Activity == 5] <- "Standing"
outputDataFrame$Activity[outputDataFrame$Activity == 6] <- "Laying"
outputDataFrame$Activity <- as.factor(outputDataFrame$Activity)
#apply meaningful names from to the numeric labels for the 30 Subjects
outputDataFrame$Subject <- as.character(outputDataFrame$Subject)
outputDataFrame$Subject[outputDataFrame$Subject == 1] <- "Subject 1"
outputDataFrame$Subject[outputDataFrame$Subject == 2] <- "Subject 2"
outputDataFrame$Subject[outputDataFrame$Subject == 3] <- "Subject 3"
outputDataFrame$Subject[outputDataFrame$Subject == 4] <- "Subject 4"
outputDataFrame$Subject[outputDataFrame$Subject == 5] <- "Subject 5"
outputDataFrame$Subject[outputDataFrame$Subject == 6] <- "Subject 6"
outputDataFrame$Subject[outputDataFrame$Subject == 7] <- "Subject 7"
outputDataFrame$Subject[outputDataFrame$Subject == 8] <- "Subject 8"
outputDataFrame$Subject[outputDataFrame$Subject == 9] <- "Subject 9"
outputDataFrame$Subject[outputDataFrame$Subject == 10] <- "Subject 10"
outputDataFrame$Subject[outputDataFrame$Subject == 11] <- "Subject 11"
outputDataFrame$Subject[outputDataFrame$Subject == 12] <- "Subject 12"
outputDataFrame$Subject[outputDataFrame$Subject == 13] <- "Subject 13"
outputDataFrame$Subject[outputDataFrame$Subject == 14] <- "Subject 14"
outputDataFrame$Subject[outputDataFrame$Subject == 15] <- "Subject 15"
outputDataFrame$Subject[outputDataFrame$Subject == 16] <- "Subject 16"
outputDataFrame$Subject[outputDataFrame$Subject == 17] <- "Subject 17"
outputDataFrame$Subject[outputDataFrame$Subject == 18] <- "Subject 18"
outputDataFrame$Subject[outputDataFrame$Subject == 19] <- "Subject 19"
outputDataFrame$Subject[outputDataFrame$Subject == 20] <- "Subject 20"
outputDataFrame$Subject[outputDataFrame$Subject == 21] <- "Subject 21"
outputDataFrame$Subject[outputDataFrame$Subject == 22] <- "Subject 22"
outputDataFrame$Subject[outputDataFrame$Subject == 23] <- "Subject 23"
outputDataFrame$Subject[outputDataFrame$Subject == 24] <- "Subject 24"
outputDataFrame$Subject[outputDataFrame$Subject == 25] <- "Subject 25"
outputDataFrame$Subject[outputDataFrame$Subject == 26] <- "Subject 26"
outputDataFrame$Subject[outputDataFrame$Subject == 27] <- "Subject 27"
outputDataFrame$Subject[outputDataFrame$Subject == 28] <- "Subject 28"
outputDataFrame$Subject[outputDataFrame$Subject == 29] <- "Subject 29"
outputDataFrame$Subject[outputDataFrame$Subject == 30] <- "Subject 30"
outputDataFrame$Subject <- as.factor(outputDataFrame$Subject)
#apply meaningful names from to the measures
names(outputDataFrame) <- gsub("Acc", "Accelerator", names(outputDataFrame))
names(outputDataFrame) <- gsub("Mag", "Magnitude", names(outputDataFrame))
names(outputDataFrame) <- gsub("Gyro", "Gyroscope", names(outputDataFrame))
names(outputDataFrame) <- gsub("^t", "time", names(outputDataFrame))
names(outputDataFrame) <- gsub("^f", "frequency", names(outputDataFrame))
#and finally, finally! write out the desired result to a file, whew.
write.table(outputDataFrame, "TidyDamsungData.txt", sep = ",", row.names = FALSE)