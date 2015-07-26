# GetAndCleanDataProject
Repo for the R script created for the course project for the Getting and Cleaning Data course on Coursera
run_analysis.R is an R script created to satisfy the requirement of the course project assignment in the Getting and Cleaning Data course offered via coursera.org.

This script is intended to be more or less fully automatic: it is not necessary for an Internet-connected user to download the data file or uncompress it, since the script itself handles those tasks.

The script creates a directory into which the data file is downloaded.  When that file is uncompressed, it creates another directory containing all the files in the archive.

The script selects the relevant files from the entire set of files in the archive, and performs various operations on them that are documented in the script itself.

The end result is a text file called TidySamsungData.txt that is written to the current working directory.  This file is a comma-delimited, quotation-mark text-qualified file that can be imported, for example, into Excel.

The operations performed are, just as in the assignment specification:

1.Merges the training and the test sets to create one data set.
2.Extracts only the measurements on the mean and standard deviation for each measurement. 
3.Uses descriptive activity names to name the activities in the data set
4.Appropriately labels the data set with descriptive variable names. 
5.From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

Run the file in R, sit back, and enjoy the resulting text file, that can easily be used in subsequent analyses.
