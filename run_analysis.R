packages <- c("data.table", "reshape2")
sapply(packages, require, character.only=TRUE, quietly=TRUE)
download.file('https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip', file.path(getwd(), "dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")
activityLabels <- fread(file.path(getwd(), "UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("classLabels", "activityName"))
att <- fread(file.path(getwd(), "UCI HAR Dataset/features.txt")
                  , col.names = c("index", "featureNames"))
attwd <- grep("(mean|std)\\(\\)", att[, featureNames])
measure <- att[featuresWanted, featureNames]
measure <- gsub('[()]', '', measure)
training <- fread(file.path(getwd(), "UCI HAR Dataset/train/X_train.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(training, colnames(training), measure)
trainingAct <- fread(file.path(getwd(), "UCI HAR Dataset/train/Y_train.txt")
                         , col.names = c("Activity"))
trainingSub <- fread(file.path(getwd(), "UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("SubjectNum"))
training <- cbind(trainingSub, trainingAct, training)
testing <- fread(file.path(getwd(), "UCI HAR Dataset/test/X_test.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(testing, colnames(testing), measure)
testact <- fread(file.path(getwd(), "UCI HAR Dataset/test/Y_test.txt")
                        , col.names = c("Activity"))
testsub <- fread(file.path(getwd(), "UCI HAR Dataset/test/subject_test.txt")
                      , col.names = c("SubjectNum"))
testing <- cbind(testsub, testact, testing)
fusion <- rbind (training, testing)
fusion[["Activity"]] <- factor(fusion[, Activity]
                                 , levels = activityLabels[["classLabels"]]
                                 , labels = activityLabels[["activityName"]])

fusion[["SubjectNum"]] <- as.factor(fusion[, SubjectNum])
fusion <- reshape2::melt(data = fusion, id = c("SubjectNum", "Activity"))
fusion <- reshape2::dcast(data = fusion, SubjectNum + Activity ~ variable, fun.aggregate = mean)

data.table::fwrite(x = fusion, file = "tidyData.txt", quote = FALSE)