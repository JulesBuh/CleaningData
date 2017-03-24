## the code is distributed AS-IS and no responsibility implied or explicit can be addressed to the author for its use or misuse
##run_analysis.R----
##1.Merges the training and the test sets to create one data set.
##2.Extracts only the measurements on the mean and standard deviation for each 
##measurement. 
##3.Uses descriptive activity names to name the activities in the data set
##4.Appropriately labels the data set with descriptive variable names. 
##5.From the data set in step 4, creates a second, independent tidy data set 
##with the average of each variable for each activity and each subject.
loadAssignment<-function() {

#0-load prerequisites---
      library(dplyr)
      
#1-Define functions----
      
##1.1sourceAssignment()--
      sourceAssignment<-function(dataDir="data",
                                 dirName="UCI HAR Dataset",
                                 ext="zip",
                                 url="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"){
            
            ##Description----
            ##source the raw data for the default dataset
            #Example
            #sourceAssignment(dataDir="data")
            #input arguments
            # 
            #Returns
            # The downloaded folder into the specified folder of the project
            ##0 Default inputs ----
            fileNameExt<-paste(dirName,ext,sep=".")
            old.dir<-getwd()  #keeps the root in memory
            dataDirPath<<-paste(old.dir,dataDir,sep="/")
            ##1 Function body ----
            #0 setting the working directory
            if(!dir.exists(dataDirPath)){
                  dir.create(dataDir)
                  setwd(dataDirPath)
            }
            setwd(dataDirPath)
            
            #1.0 Actions to perform on a zip file----
            if(ext=="zip"){
                  if(!dir.exists(dirName)){
                        #1.0.1 download the data to the working directory if it doesn't already exist
                        if(!file.exists(fileNameExt)){
                              download.file(url,fileNameExt)
                              message("download complete...")
                        }
                        #1.0.2 unzip the file
                        unzip(fileNameExt)
                        #1.0.3 condition
                        dirPresent<-dir.exists(dirName)
                        #1.0.3A stop if folder is not present
                        if(!dirPresent){
                              #check to ensure download and unzip worked succesfully
                              stop("download and unzip of the default set has failed")
                        }
                        #1.0.3B continue if folder is present
                        if(dirPresent){
                              # Deletes the zip file
                              file.remove(fileNameExt)
                              message("unzip complete...")
                        }
                  }
            }
            #1.1 Actions to perform on other filtetypes----
            if(ext!="zip"){
                  stop("no other file types have been defined")
                  #Other conditions to be added here for other file types and arguments can
                  #then be created in the function itself for file name extension and working
                  #directory
            }
            ##9 Returns----
            dataDirPath<<-paste(dataDirPath,dirName,sep="/")
            setwd(old.dir) # sets the working directory back to the original place
            message(paste("\r\nThe files have been retrieved",
                          "and their location has been set to"))
            print(dataDirPath)
            return(dataDirPath)
      }
      
##1.2readAssignment()--
      readAssignmentData <- function(datadir=dataDirPath,fileType=".txt"){
            ##Description----
            ##Reads the source data and returns the data as a list of data frames
            
            #Example
            #readAssignmentData()
            
            #input arguments
            # 'dataDir' is the directory where the data is stored. the default is 
            # dataDirPath as it is assumed that the sourceAssignement function has 
            # already ran where this variable was set
            
            #Returns
            # A list of dataframes that are named according to what it is ready for 
            # further cleaning
            
            ##0 inputs ----
            #organise filepath infromation and retain useful paths for later functions
            if (!exists("dataDirPath")){
                  warning("The sourceAssignment() function is required to run first")
                  return(NULL)
            }
            old.dir<-getwd()
            #0 setting the working directory     
            setwd(datadir)    
            
            dataSetNames<-list.dirs(".",recursive = FALSE, full.names=FALSE)
            
            metaData<- data.frame(set=sort(as.character(replicate(3,dataSetNames))),
                                  name=c("obsv","subjectIDobsv","activityObsv"),
                                  path=c("/X_","/subject_","/y_"),
                                  class=c("numeric","factor","factor"),
                                  colHeader=c(NA,"index","subjectID"))
            
            ##1 Function body ----
            
            ##1.1 Construct the path names ----
            dataPaths<-c(paste("./",metaData[,"set"],
                               metaData[,"path"],
                               metaData[,"set"],fileType,
                               sep="",collape=""))
            
             
            if(!prod(file.exists(dataPaths))){
                  #exits the function if the path doesn't exist.
                  warning("file paths do not exist")
                  return(NULL)
            }
            #update the path column
            metaData[,"path"]<- dataPaths
            
            ##1.2 Read in the data from using the path names----
            #instantiate a list of blank dataframes
            observationData<-replicate(nrow(metaData),data.frame(NULL))
            #assign names to the list by the filepath name
            names(observationData)<-metaData[,"path"]
            
            expectedValues<-NULL
            expectedLength<-NULL
            for (set in 1:nrow(metaData)){
                  #for each data frame, select it by filepath name and read in the data from the filepath
                  message(paste("reading",dataPaths[set],"..."))
                  observationData[[metaData$path[set]]]<-read.table(metaData$path[set],colClasses = as.character(metaData$class[set]))
                  message(paste("...completed"))
                  
                  #stores a maximum number of expected unique values in the labels data
                  #and the length of each lists for verification that lists are the same length
                  #when they are joined later.
                  if(metaData$class[set]=="factor"){
                        expectedValues[[set]]<-(levels(observationData[[set]][[1]]))
                        metaData[set,"expMaxOptions"]<- length(expectedValues[[set]])
                  }else{
                        metaData[set,"expMaxOptions"]<- ncol(observationData[[set]])
                  }
                  expectedLength[set]<-nrow(observationData[[set]])
            }
            metaData[,"expObsCount"]<- expectedLength 
            
            #The column names within the activity and subject tables are set
            names(observationData$'./test/y_test.txt')<-"index"
            names(observationData$'./train/y_train.txt')<-"index"
            names(observationData$'./test/subject_test.txt')<-"subjectID"
            names(observationData$'./train/subject_train.txt')<-"subjectID"
            
            
            ##9 Returns----  
            ##9.1 Sets the metadataset--      
            contentMetaData<<-metaData
            message("\r\n","Below is a summary of the data content read:")
            print(contentMetaData)
            
            ##9.2 Sets the dataset--
            contentAssignmentData<<-observationData
            
            #clear the individual lists from memory that are no longer needed
            rm("metaData")
            rm("observationData")
            
            # sets the working directory back to the original place to avoid user confusion
            setwd(old.dir)
            return(contentMetaData)
      }
      
##1.3readLabels()--
      readLabelData<-function(fileType=".txt"){
            ##Description----
            # Appropriately labels the data set with descriptive variable names.
            
            #Example
            # renameLabels("www./1/.csv","www./2/.csv")
            
            
            #input arguments
            # 'arg3' 
            
            #Returns
            # A filtered data set
            
            ##0 Loads prerequisites----
            #load the dplyr library
            if (!exists("dataDirPath")){
                  warning("The sourceAssignment() function is required to run first")
                  return(NULL)
            }
            if (!exists("contentAssignmentData")){
                  warning("The readAssignmentData() function is required to run first")
                  return(NULL)
            }
            ##1 Function body ----
            #1.1 set the working directories ready to read the labe data----
            old.dir<-getwd()
            setwd(dataDirPath)
            labelPaths<-list.files(".",pattern = fileType)
            labelMatrix <- data.frame(path=as.character(labelPaths))
            
            #1.2 Does a first pass of the data read to try to match up with observation data----
            #instantiate a list of blank dataframes
            labelSets<-replicate(nrow(labelMatrix),data.frame(NULL))
            for (file in 1:nrow(labelMatrix)){
                  ##initial read of data to determine matching up with the observation data
                  labelSets[[file]]<-readLines(as.character(labelMatrix$path[[file]]))
                  
                  labelMatrix[file,"length"]<- length(labelSets[[file]])
                  
                  #cycle thorough the dataset conent matrix metadata to match the lengths
                  #up to the lengths of the labels
                  for (dataset in 1:nrow(contentMetaData)){
                        if(length(labelSets[[file]])==contentMetaData$expMaxOptions[dataset]){
                              
                              #adds the labels path to the content metadata matrix
                              contentMetaData$labelsfile[dataset]<-as.character(labelMatrix$path[[file]])
                              #adds the path to the labels metadata matrix
                              labelMatrix[file,"name"]<-contentMetaData$name[dataset]
                        }
                  }
            }
            #update the metaData with the new information
            contentMetaData<<-contentMetaData
            
            labelSets<-NULL
            
            #1.3 Reads the label data in properly----
            #creates a temporary list of names to use as names for the dataframes in labelSets
            tempName<-c(NULL)
            
            #reads the labelSets in properly
            for (file in 1:nrow(labelMatrix)){
                  if(!is.na(labelMatrix$name[file])){
                        labelSets[[file]]<-read.table(as.character(labelMatrix$path[[file]]))
                        tempName[file]<-as.character(labelMatrix$name[file])
                  }
                  
            }
            #assigns a name to the LabelsdataSet that co-ordinates with the names in 
            #the Content metadata
            names(labelSets)<-tempName 
            
            #assign headers to the labels dataframes, 'index' and 'label' 
            for(labelSet in 1:length(labelSets)){
                  #assi
                  if(length(labelSets[[labelSet]])==2){
                        
                        names(labelSets[[labelSet]])<-c("index","label")
                        
                        #as there are duplicate header names, these will need to be altered slightly to make
                        #them unique in order for dplyr and tidyr to work. In order to make them distinguishable
                        #the altered header names will append a number sequence separated by '~~~' 
                        labelSets[[labelSet]][["label"]]<-make.unique(as.character(labelSets[[labelSet]][["label"]]),sep="~~~")
                        
                  }
                  #prepare the dataframes as tables using the dplyr library
                  tbl_df(labelSets[[labelSet]])
            }
            
            ##9 Returns----
            setwd(old.dir)
            labelSetTbls<<-labelSets
            labelMetaData<<-labelMatrix
            rm(labelMatrix)
            message("\r\n","Below is a summary of the label data:")
            print(labelMetaData)
            return(labelMetaData)
      }
      
##1.4renameVariablesLabelsandIndexedValues()--
      assignLabelDescriptions<-function(){
            ##Description----
            # Uses descriptive activity names to name the activities in the data set
            
            #Example
            # renameDescription()
            
            #input arguments
            #  
            #Returns
            # A filtered data set
            
            ##0 Validates inputs----
            library(dplyr) #this will hve already been loaded previously, could be 
            #removed from here and placed in a central script instead.
            
            if (!exists("dataDirPath")){
                  warning("The sourceAssignment() function is required to run first")
                  return(NULL)
            }
            if (!exists("contentAssignmentData")){
                  warning("The readAssignmentData() function is required to run first")
                  return(NULL)
            }
            if (!exists("labelMetaData")){
                  warning("The readLabelData() function is required to run first")
                  return(NULL)
            }
            ##1 Function body ----
            
            #1.1 Applies appropriate descriptions to the dataset----
            names(contentAssignmentData$'./test/X_test.txt')<-labelSetTbls[["obsv"]][["label"]]
            names(contentAssignmentData$'./train/X_train.txt')<-labelSetTbls[["obsv"]][["label"]]
            
            #1.2 Matches activity index to activity labels and assigns them to the full dataset----
            contentAssignmentData$'./test/X_test.txt'$activity<-as.character(labelSetTbls$activityObsv$label[contentAssignmentData$`./test/y_test.txt`$index])
            contentAssignmentData$'./train/X_train.txt'$activity<-as.character(labelSetTbls$activityObsv$label[contentAssignmentData$`./train/y_train.txt`$index])
            
            #1.3 adds the subjectID as a column----
            contentAssignmentData$'./test/X_test.txt'$subjectID<-as.character(contentAssignmentData$'./test/subject_test.txt'$subjectID)
            contentAssignmentData$'./train/X_train.txt'$subjectID<-as.character(contentAssignmentData$'./train/subject_train.txt'$subjectID)
            
            #1.4 creates a column to identify the data set group (test or train)----
            contentAssignmentData$'./test/X_test.txt'$group<-"test"
            contentAssignmentData$'./train/X_train.txt'$group<-"train"
            
            #makes all dataframes as table dataframes This assumes that the labels just applied
            # have already been made unique in the readlabels function
            for (df in 1:length(contentAssignmentData)){
                  tbl_df(contentAssignmentData[[df]])
            }
            
            #1.5 append the train table to the test table----
            unifiedData<-bind_rows(contentAssignmentData$'./test/X_test.txt',contentAssignmentData$'./train/X_train.txt') # joins two tables vertically
            
            #1.6 reorder the data so that group,subjectID,activity appear before the measured data
            unifiedData<-bind_cols(unifiedData %>% select(group,subjectID,activity),select(unifiedData,-group,-subjectID,-activity))
            ##9 Returns----
            message("\r\n","Below is a summary of 10 randomly selected variables in the final dataframe:")
            assignmentData<<- unifiedData
            str(assignmentData[as.integer(c(1:3,runif(7,4,length(assignmentData))))])
            print(paste("...","+",length(assignmentData)-10,"more variables have been read."))
            message("\r\n","...+Datasets 'test' and 'train' have been ",
                    "combined to produce ",nrow(assignmentData)," observations.")
            #cleanup 
            rm(unifiedData)
      }

#8 Run function sequence ----
      sourceAssignment();
      readAssignmentData();
      readLabelData();
      assignLabelDescriptions();
      
#9 Returns----
      #cleanup
      rm(list =c("dataDirPath", #originally created in the source data function
                 "contentAssignmentData","contentMetaData", #originally created in the read data function
                 "labelMetaData","labelSetTbls" #originally created in the read labels function
      ),envir=as.environment(parent.frame()))


      message("\r\nLicense:\r\n========
Use of this dataset in publications must be acknowledged by referencing the following publication [1] 

[1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012
This dataset is distributed AS-IS and no responsibility implied or explicit can be addressed to the authors or their institutions for its use or misuse. Any commercial use is prohibited.
Jorge L. Reyes-Ortiz, Alessandro Ghio, Luca Oneto, Davide Anguita. November 2012.")
      
      print("Labels have been applied and merged into a single dataframe in the variable called 'assignmentData'")
      
      }