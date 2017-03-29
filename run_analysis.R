## Author: Jules Buhagiar
## Purpose: For JHU-assignment submission only
## The code is distributed AS-IS and no responsibility implied or explicit can be addressed to the author for its use or misuse
## run_analysis.R----

##with the average of each variable for each activity and each subject.
run_analysis<-function() {
      #>DESCRIPTION----
      # Steps 1-4 of the assignment
      # 1.Merges the training and the test sets to create one data set.
      # 2.Extracts only the measurements on the mean and standard deviation for each 
      #   measurement. 
      # 3.Uses descriptive activity names to name the activities in the data set
      # 4.Appropriately labels the data set with descriptive variable names. 
      #>Example----
      # loadAssignment()
      #>Arguments----
      # No Argument are used in this function
      #>Returns----
      # assignmentData as a dataframe - this is a combined dataset with labels and
      # descriptions.
      #0-load prerequisites---
      library(dplyr)
      library(stringr)
      library(lubridate)
      #1-Define functions----


# 0.0 Preparatory Internal Functions----
      keep<-function(...){
            #>DESCRIPTION----
            # keeps a record of stating globals
            # and appends the desired variables that we wish to keep by the end of the 
            # script, thereby making all other variables and functions that are made during 
            # the running of this function as temporary.
            if(!exists("GlobalEnvKeep")){
                  GlobalEnvKeep<<-c(ls(envir = as.environment(globalenv())))
            }
            GlobalEnvKeep<<-c(GlobalEnvKeep,...)
      }
      metadata_UpdateLog<-function(){
            # DESCRIPTION----
            # updates the metadataLog time 
            # Returns----
            # Stores metadataLog list items
            
            #flattens all paths stored
            
            dirPaths<<-sapply(names(dirPathMem),dir_retrieve)
            
            metadataDataPath<-dirPaths["dirDataPath"]
            metadataDownloadPath<-dirPaths["dirDownloadPath"]
            metadataSourcePath<-dirPaths["urlSourceDataPath"]
            
            metadataRuntime<-NULL
            metadataRuntime<-lubridate::now()
      
            if(dir.exists(dir_retrieve("dirDataPath"))){
                  metadataRecoverRuntime<-lubridate::ymd_hms(file.info(dir_retrieve("dirDataPath"))[["ctime"]])
            }
           
            if(exists("sourceData")&!dir.exists(dir_retrieve("dirDataPath"))){
                  #the souce data must have been deleted or moved and some of the metadata content no longer applies
                  sourceData$metadataLog$prevrun[length(sourceData$metadataLog$prevrun)+1]<<-sourceData$metadataLog$lastrun[[1]]
                  sourceData$metadataLog$download[length(sourceData$metadataLog$prevrun)+1]<<-metadataRuntime
                  sourceData$metadataLog$lastrun<<-(metadataRuntime)
                  sourceData$metadataLog$DownLoadPath<<-data.frame(name=metadataDownloadPath,
                                                        Date=metadataRuntime)
                  sourceData$metadataLog$SourcePath<<-data.frame(name=metadataSourcePath,
                                                      Date=metadataRuntime)
                  sourceData$metadataLog$DataPath<<-data.frame(name=metadataDataPath,
                                                    Date=metadataRuntime)  
            }
            if(exists("sourceData")&dir.exists(dir_retrieve("dirDataPath"))){
                  #the souce data and metadata are intact
                  sourceData$metadataLog$prevrun[length(sourceData$metadataLog$prevrun)+1]<<-sourceData$metadataLog$lastrun[[1]]
                  sourceData$metadataLog$lastrun<<-(metadataRuntime)
                  sourceData$metadataLog$DataPath<<-data.frame(name=metadataDataPath,
                                                      Date=metadataRuntime)            
            }
            
            if(!exists("sourceData")){
                  metadata_CreateLog<-function(){
                        # DESCRIPTION----
                        # creates a new log 
                        # Returns----
                        # Stores metadataLog list items
                        
                        if(!exists("sourceData")&!dir.exists(dir_retrieve("dirDataPath"))){
                              #create a new metadataLog variable
                              sourceData$metadataLog<<-NULL
                              sourceData$metadataLog$prevrun<<-metadataRuntime
                              sourceData$metadataLog$firstrun<<-metadataRuntime
                              sourceData$metadataLog$lastrun<<-metadataRuntime
                              sourceData$metadataLog$download<<-metadataRuntime
                              sourceData$metadataLog$DataPath<<-data.frame(name=metadataDataPath,
                                                                Date=metadataRuntime)
                              sourceData$metadataLog$DownLoadPath<<-data.frame(name=metadataDownloadPath,
                                                                    Date=metadataRuntime)
                              sourceData$metadataLog$SourcePath<<-data.frame(name=metadataSourcePath,
                                                                  Date=metadataRuntime)
                              
                        }
                        if(!exists("sourceData")&dir.exists(dir_retrieve("dirDataPath"))){
                              #download must have happened previously and the metadata variable hasn't been saved
                              sourceData$metadataLog<<-NULL
                              sourceData$metadataLog$firstrun<<-metadataRecoverRuntime
                              sourceData$metadataLog$prevrun<<-c(metadataRecoverRuntime,NA)
                              sourceData$metadataLog$lastrun<<-metadataRuntime
                              sourceData$metadataLog$download<<-metadataRecoverRuntime
                              sourceData$metadataLog$DataPath<<-data.frame(name=metadataDataPath,
                                                                Date=metadataRuntime)
                              sourceData$metadataLog$DownLoadPath<<-data.frame(name=metadataDownloadPath,
                                                                    Date=metadataRecoverRuntime)
                              sourceData$metadataLog$SourcePath<<-data.frame(name=metadataSourcePath,
                                                                  Date=metadataRecoverRuntime)
                        }
                  }
                  metadata_CreateLog();
            }
      }
      dir_store<-function(newFolder="",
                           nameInMemory ="dataPath",
                           currentFolder=getwd(),rel="relative"){
            # DESCRIPTION----
            # creates a directory path named list 
            # Returns----
            # Stores a list of named paths in memory and returns a path string to dirCurrentPath
            if(rel=="absolute"){
                  currentFolder=newFolder
                  newFolder=""
            }
            if(rel!="absolute"){
                  currentFolder<-currentFolder
            }
            
            if(!exists("dirPathMem")){
                  currentFolder=getwd()
                  dirPathMem<<-list(currentFolder)
            }
            if(!exists(paste("dirPathMem",nameInMemory,sep="$"))){
      
                  dirPathMem[nameInMemory]<<-stringr::str_split(currentFolder,"\\.*/\\.*")
      
            }
            dir_storeToMem<-function(nameInMemory ="dataPath"){
                  if(is.null(newFolder)){newFolder=""}
                  dirPathMem[[nameInMemory]][length(dirPathMem[[nameInMemory]])+1]<<-newFolder
                  dir_retrieve(nameInMemory)
                  return(dirCurrentPath)
            }
            dir_storeToMem(nameInMemory)
      }
      dir_retrieve<-function(nameInMemory ="dataPath"){
            dirCurrentPath<<-paste(dirPathMem[[nameInMemory]],collapse="/")
            return(dirCurrentPath)
      }
      dir_Name_ext<-function(dirName,dirSourceUrl="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"){
            #>DESCRIPTION
            # A series of functions that manages the initial download process and different
            # conditions for different extensions
            #>EXAMPLE
            # dir_Name_ext(intended name of the downloaded file with its extension)
            dir_source_Ext<-function(dirSourceUrl="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"){
                  dirSourceExt<-strsplit(dirSourceUrl,"\\.")
                  dirSourceExt<-dirSourceExt[[1]][length(dirSourceExt[[1]])]
                  return(dirSourceExt)
            }
            dirSourceExt<<-dir_source_Ext(dirSourceUrl);
            dirNameExt<<-paste(dirName,dirSourceExt,sep=".")
            return(dirNameExt)
      }
      rename_Label<- function(label){
            ##>Description----
            # Removes characters in a systematic way.
            #>Example
            # renamelabel(label)
            #>Arguments
            # label
            #>Returns
            # Transformed Labels as a vector
            # 0 Prerequisites----
            library(stringr)
            # 1 Function Body----
            label<-label%>%
                  str_replace_all("\\(","")%>%
                  str_replace_all("\\)","")%>%
                  str_replace_all("_","")%>%
                  str_replace_all("-","-")%>%
                  str_replace_all(",","")%>%
                  str_replace_all("Acc","\\.acceleration")%>%
                  str_replace_all("Mag","\\.magnitude")%>%
                  str_replace("t([BG])","time\\.\\1")%>%
                  str_replace("f([BG])","frequency\\.\\1")%>%
                  tolower()%>% # I would disagree with the week 4 course on this
                  #it is best practice to do lower followed by TitleCase for each word
                  make.unique(sep="~~~")
            # 9 Returns
            sourceData$metadataLog$sample<<-paste(paste(unlist(LETTERS),unlist(letters),sep="",collapse=""),
                                      c("tB","tG")," ","(",")","-","_",",",sep=" ")
            
            
            return(label)
            
      }

# 1.1 source_Assignment()----
source_Assignment<-function(dirLoc=NULL,
                           dirName="UCI HAR Dataset",
                           dirSourceUrl="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"){
      
#>Description----
      # source the raw data for the default dataset
      #>Example----
      # sourceAssignment(dirLoc="data")
      #>Input arguments----
      # 'dirLoc' is an optional folder to add within the working directory
      # 'dirName' is the name of the directory in which the data will sit.
      # 'dirSourceUrl' is the url to retrieve the data from
      #>Returns----
      # The downloaded folder into the specified folder of the projectl
      
##0 Preparation ----
      # 0.0 Creates the global variable to which the sourceData information will be written to
      sourceData<<-NULL
      keep(c("sourceData"))
      # 0.1 Keeps the starting folder in memory
      dir_store(nameInMemory="dirOld")

      # 0.0 Stores the source url path
      dir_store(dirSourceUrl,nameInMemory="urlSourceDataPath",rel="absolute")
      
      # 0.2 Stores the new path where the data will download to
      dir_store(dirLoc,nameInMemory="dirDownloadPath")
      if(!dir.exists(dir_retrieve("dirDownloadPath"))){
            dir.create(dirLoc)
      }
      # 0.3 Stores the new path where the data will be located
      dir_store(dirName,nameInMemory="dirDataPath")     
      
      # 0.4 find the extension of the source
      dir_Name_ext(dirName,dirSourceUrl)
      
      # 0.9 updatelogEntry
      metadata_UpdateLog()
##1 Function body ----

      #1.0 Set the download folder----
      setwd(dir_retrieve("dirDownloadPath"))
      #1.1 Download the source if not already downloaded
      if(!dir.exists(dir_retrieve("dirDataPath"))){
            download.file(dirSourceUrl,dirNameExt)
            #1.9 report back to user interface console
            message("download complete...")
            #2.0 Actions to perform on a zip file----
            if(dirSourceExt=="zip"){
                  
                  #2.0.1 unzip the file
                  unzip(dirNameExt)
                  #2.0.2 condition
                  dirPresent<-dir.exists(dir_retrieve("dirDataPath"))
                  #2.0.2A stop if folder is not present
                  if(!dirPresent){
                        #check to ensure download and unzip worked succesfully
                        stop("download and unzip of the default set has failed")
                  }
                  #2.0.2B continue if folder is present
                  if(dirPresent){
                        # Deletes the zip file
                        file.remove(dirNameExt)
                        message("unzip complete...")
                        setwd(dir_retrieve("dirDataPath"))
                  }
            }
            #2.1 Actions to perform on other filtetypes----
            if(dirSourceExt!="zip"){
                  stop("no other file types have been defined")
                  #Other conditions to be added here for other file types and arguments can
                  #then be created in the function itself for file name extension and working
                  #directory
            }
      }

##9 Returns----

      
      setwd(dir_retrieve("dirOld")) # sets the working directory back to the original place
      message(paste("\r\nThe files have been retrieved",
                    "and their location has been set to"))
      print(dir_retrieve("dirDataPath"))
      return(sourceData$metadataLog)
}
# 1.2 read_Assignment_Data()----
read_Assignment_Data <- function(fileType=".txt"){
      #>Description----
      # Reads the source data and returns the data as a list of data frames
      
      #>Example----
      # readAssignmentData()
      
      #>input arguments----
      # 'dataDir' is the directory where the data is stored. the default is 
      # dataDirPath as it is assumed that the sourceAssignement function has 
      # already ran where this variable was set
      
      #>Returns----
      # A list of dataframes that are named according to what it is ready for 
      # further cleaning
      
      ##0 inputs ----
      #organise filepath infromation and retain useful paths for later functions
      if (!(exists("dirPathMem")||exists("sourceData"))){
            warning("The sourceAssignment() function is required to run first")
            return(NULL)
      }
      
      setwd(dir_retrieve("dirDataPath"))    
      
      sourceData$metadataLog$dataSetNames<<-list.dirs(".",recursive = FALSE, full.names=FALSE)
      sourceData$metadataLog$dirNames<<-paste("dir",stringr::str_to_title(sourceData$metadataLog$dataSetNames),sep="")
      
      #store directories
      for (d in 1:length(sourceData$metadataLog$dataSetNames)){
            dir_store(sourceData$metadataLog$dataSetNames[[d]],nameInMemory = sourceData$metadataLog$dirNames[[d]])
      }
      
      
      sourceData$metadataLog$content<<- data.frame(set=sort(as.character(replicate(3,sourceData$metadataLog$dataSetNames))),
                                       name=c("obsv","subjectIDobsv","activityObsv"),
                                       path=c("/X_","/subject_","/y_"),
                                       class=c("numeric","integer","integer"),
                                       colHeader=c(NA,"subjectID","index"))
      
      ##1 Function body ----
      
      ##1.1 Construct the path names ----
      filePaths<-c(paste("./",sourceData$metadataLog$content[,"set"],
                         sourceData$metadataLog$content[,"path"],
                         sourceData$metadataLog$content[,"set"],fileType,
                         sep=""))
      
      
      if(!prod(file.exists(filePaths))){
            #exits the function if the path doesn't exist.
            warning("file paths do not exist")
            return(NULL)
      }
      #update the path column
      sourceData$metadataLog$content[,"path"]<<- filePaths
      
      ##1.2 Read in the data from using the path names----
      sourceData$content<<-NULL
      #instantiate a list of blank dataframes
      sourceData$content$observationData<<-replicate(nrow(sourceData$metadataLog$content),data.frame(NULL))
      #assign names to the list by the filepath name
      names(sourceData$content$observationData)<<-sourceData$metadataLog$content[,"path"]
      
      expectedValues<-NULL
      expectedLength<-NULL
      for (set in 1:nrow(sourceData$metadataLog$content)){
            #for each data frame, select it by filepath name and read in the data from the filepath
            
            message(paste("reading",filePaths[set],"..."))
            
            #sets the variable to read and write to
            dataframeID<-sourceData$metadataLog$content$path[set]
            fileName<-sourceData$metadataLog$content$path[set]
            colClass<-as.character(sourceData$metadataLog$content$class[set])
            
            #reads and writes the data to the content$observationData
            sourceData$content$observationData[[dataframeID]]<<-read.table(fileName,colClasses = colClass, stringsAsFactors = FALSE)
            message(paste("...completed"))
            
            #stores a maximum number of expected unique values in the labels data
            #and the length of each lists for verification that lists are the same length
            #when they are joined later.
            if(sourceData$metadataLog$content$class[set]=="integer"){
                  expectedValues[[set]]<-(levels(as.factor(sourceData$content$observationData[[set]][[1]])))
                  sourceData$metadataLog$content[set,"expMaxOptions"]<<-length(expectedValues[[set]])
            }else{
                  sourceData$metadataLog$content[set,"expMaxOptions"]<<-ncol(sourceData$content$observationData[[set]])
            }
            expectedLength[set]<-nrow(sourceData$content$observationData[[set]])
      }
      sourceData$metadataLog$content[,"expObsCount"]<<-expectedLength 
      
      #The column names within the activity and subject tables are set
            
      #names(sourceData$content$observationData$'./test/y_test.txt')<-"index"
      #names(sourceData$content$observationData$'./train/y_train.txt')<-"index"
      #names(sourceData$content$observationData$'./test/subject_test.txt')<-"subjectID"
      #names(sourceData$content$observationData$'./train/subject_train.txt')<-"subjectID"
      
      #create dataframes as tbl_df
      for (df in 1:length(sourceData$content$observationData)){
            sourceData$content$observationData[[df]]<<-dplyr::tbl_df(sourceData$content$observationData[[df]])
      }
      
      ##9 Returns----  
      ##9.1 Sets the metadataset--      
      message("\r\n","Below is a summary of the data content read:")
      print(sourceData$metadataLog$content)
      
      #clear the individual lists from memory that are no longer needed
      rm("d","set","expectedValues","expectedLength","fileType")
      
      # sets the working directory back to the original place to avoid user confusion
      setwd(dir_retrieve("dirOld"))
      return(sourceData$metadataLog)
}

# 1.3 read_Label_Data()----
read_Label_Data<-function(fileType=".txt"){
      ##>Description----
      # Appropriately labels the data set with descriptive variable names.
      
      #>Example-----
      # renameLabels("www./1/.csv","www./2/.csv")
      #>input arguments----
      # 'filetype 
      #>Returns----
      # A filtered data set
      ##0 Loads prerequisites----
      #load the dplyr library
      if (!(exists("dirPathMem")|exists("sourceData"))){
            warning("The sourceAssignment() function is required to run first")
            return(NULL)
      }
      if (!exists("source")){
            warning("The readAssignmentData() function is required to run first")
            return(NULL)
      }
      ##1 Function body ----
      #1.1 set the working directories ready to read the labe data----
      
      setwd(dir_retrieve("dirDataPath"))   
      
      labelPaths<-list.files(".",pattern = fileType)
      sourceData$metadataLog$labelSource <<- data.frame(path=as.character(labelPaths),readDate=lubridate::now())
      
      #1.2 Does a first pass of the data read to try to match up with observation data----
      #instantiate a list of blank dataframes
      sourceData$content$sourceLabels<<-replicate(nrow( sourceData$metadataLog$labelSource),data.frame(NULL))
      for (file in 1:nrow(sourceData$metadataLog$labelSource)){
            
            
            ##initial read of data to determine matching up with the observation data
            sourceData$content$sourceLabels[[file]]<<-readLines(as.character( sourceData$metadataLog$labelSource$path[[file]]))
            
            sourceData$metadataLog$labelSource[file,"length"]<<- length(sourceData$content$sourceLabels[[file]])
            
            #cycle thorough the dataset conent metadata to match the lengths
            #up to the lengths of the labels
            for (dataset in 1:nrow(sourceData$metadataLog$content)){
                  if(length(sourceData$content$sourceLabels[[file]])==sourceData$metadataLog$content$expMaxOptions[dataset]){
                        
                        #adds the labels path to the content metadata matrix
                        sourceData$metadataLog$content$labelsfile[dataset]<<-as.character( sourceData$metadataLog$labelSource$path[[file]])
                        #adds the path to the labels metadata matrix
                        sourceData$metadataLog$labelSource[file,"name"]<<-sourceData$metadataLog$content$name[dataset]
                  }
            }
      }
      
      
      sourceData$content$sourceLabels<<-NULL
      
      #1.3 Reads the label data in properly----
      #creates a temporary list of names to use as names for the dataframes in content$sourceLabels
      tempName<-c(NULL)
      
      #reads the content$sourceLabels in properly
      for (file in 1:nrow(sourceData$metadataLog$labelSource)){
            if(!is.na(sourceData$metadataLog$labelSource$name[file])){
                  sourceData$content$sourceLabels[[file]]<<-read.table(as.character(sourceData$metadataLog$labelSource$path[[file]]))
                  tempName[file]<-as.character( sourceData$metadataLog$labelSource$name[file])
            }
            
      }
      #assigns a name to the LabelsdataSet that co-ordinates with the names in 
      #the Content metadata
      names(sourceData$content$sourceLabels)<<-tempName 
      rm(tempName)
      
      #create dataframes as tbl_df
      for (df in 1:length(sourceData$content$sourceLabels)){
            sourceData$content$sourceLabels[[df]]<<-dplyr::tbl_df(sourceData$content$sourceLabels[[df]])
      }
      
      #assign headers to the labels dataframes, 'index' and 'label' 
      for(df in 1:length(sourceData$content$sourceLabels)){
            if(length(sourceData$content$sourceLabels[[df]])==2){
                  names(sourceData$content$sourceLabels[[df]])<<-c("index","label")
            }
      }
      
      sourceData$content$renamedLabels<<-sourceData$content$sourceLabels
      #assign headers to the labels dataframes, 'index' and 'label' 
      for(df in 1:length(sourceData$content$renamedLabels)){
            if(length(sourceData$content$renamedLabels[[df]])==2){
                  #rename the labels
                  sourceData$content$renamedLabels[[df]][["label"]]<<-rename_Label(sourceData$content$renamedLabels[[df]][["label"]])
                  sourceData$metadataLog$sampleRename<<-rename_Label(sourceData$metadataLog$sample)
            }
            #prepare the dataframes as tables using the dplyr library
            #tbl_df(sourceData$content$sourceLabels[[labelSet]])
      }
      ##9 Returns----
      setwd(dir_retrieve("dirOld"))
      
      message("\r\n","Below is a summary of the label data:")
      print(sourceData$metadataLog$labelSource)
      return(sourceData$metadataLog)
}
# 2.0 map_descriptions()----
map_descriptions<-function(){
      
      #The column names within the activity and subject obervation data tables are set first
      selectData<-sourceData$metadataLog$content$name=="subjectIDobsv"|sourceData$metadataLog$content$name=="activityObsv"
      selectedframe<-sourceData$metadataLog$content$path[selectData]
      LabelstoBind<-sourceData$metadataLog$content$colHeader[selectData]
      
      for(df in 1:length(selectedframe)){
            labelToBind<-as.character(LabelstoBind[[df]])
            
            names(sourceData$content$observationData[selectedframe][[df]])<<-labelToBind
            
      }
      
      #The column names within the observation table is then set from the features
      labelSetToBind<-"obsv"
      selectData<-sourceData$metadataLog$content$name==labelSetToBind
      selectedframe<-sourceData$metadataLog$content$path[selectData]
      
      for(df in 1:length(selectedframe)){
            labelsToBind<-sourceData$content$renamedLabels[[labelSetToBind]][["label"]]
            
            names(sourceData$content$observationData[selectedframe][[df]])<<-labelsToBind
      }
      
      #The data values for the activties are retrieved and written into a new column called activity
      descriptionSetToBind<-"activityObsv"
      selectData<-sourceData$metadataLog$content$name==descriptionSetToBind
      selectedframe<-sourceData$metadataLog$content$path[selectData]
      for(df in 1:length(selectedframe)){
            index<-unlist(sourceData$content$observationData[[selectedframe[df]]]["index"])
            activityDescription<-sourceData$content$renamedLabels[[descriptionSetToBind]][["label"]]
            
            sourceData$content$observationData[[selectedframe[df]]][["activity"]]<<-activityDescription[index]
      }
      
      for (df in 1:length(sourceData$content$observationData)){
            sourceData$content$observationData[[df]]<<-dplyr::tbl_df(sourceData$content$observationData[[df]])
      }
}
# 3.0 append_Columns()----
append_Columns<-function(){
      transformData<<-NULL
      keep(c("transformData"))  
      transformData$content$observationData$'./test/X_test.txt'<<-sourceData$content$observationData$'./test/X_test.txt'
      transformData$content$observationData$'./train/X_train.txt'<<-sourceData$content$observationData$'./train/X_train.txt'
      
      #3.1 creates a column to identify the data set group (test)----
      sourceTransformed<-sourceData$content$observationData$'./test/X_test.txt'$group<-"test"
      transformData$content$observationData$'./test/X_test.txt'$group<<-sourceTransformed
      
      #3.2 creates a column to identify the data set group (train)----
      sourceTransformed<-sourceData$content$observationData$'./train/X_train.txt'$group<-"train"
      transformData$content$observationData$'./train/X_train.txt'$group<<-sourceTransformed
      
      #3.3 transfers the subject column to the transforms dataset----
      sourceTransformed<-sourceData$content$observationData$`./test/subject_test.txt`$subjectID       
      transformData$content$observationData$'./test/X_test.txt'$subjectID<<-sourceTransformed
      
      #3.4 transfers the subject column to the transformed dataset----     
      sourceTransformed<-sourceData$content$observationData$`./train/subject_train.txt`$subjectID     
      transformData$content$observationData$'./train/X_train.txt'$subjectID<<-sourceTransformed

      #3.5 transfers the activity column to the transformed dataset----       
      sourceTransformed<-sourceData$content$observationData$`./test/y_test.txt`$activity       
      transformData$content$observationData$'./test/X_test.txt'$activity<<-sourceTransformed

      #3.6 transfers the activity column to the transformed dataset----       
      sourceTransformed<-sourceData$content$observationData$`./train/y_train.txt`$activity     
      transformData$content$observationData$'./train/X_train.txt'$activity<<-sourceTransformed
      
}
# 3.7 merge_Datasets()----
merge_Datasets<-function(){
      transformData$full<<-dplyr::bind_rows(transformData$content$observationData$'./test/X_test.txt',
                                    transformData$content$observationData$'./train/X_train.txt')
      # 3.8 reorder the column
      transformData$full<<-dplyr::bind_cols(transformData$full %>% 
                                                 select(group,subjectID,activity),
                                           transformData$full %>% 
                                          select(-group,-subjectID,-activity))%>%
            arrange(subjectID)
      
}
# 4.0 filter_Variables()----
filter_Variables<-function(){
      #Initiate new variable where the final data will be stored
      tidyData<<-list(NULL)
      keep(c("tidyData"))
      
      #filter columns with mean and std in their name
      tidyData$filtered<<-transformData$full %>% 
            select(subjectID,activity,group,contains("mean"),contains("std")) %>%
            arrange(subjectID)
}
# 5.0 extract_Data()----
extract_Data<-function(){
      # 5.1 average dataset by subject and activity
      tidyData<<-
            tidyData$filtered %>% 
            group_by(subjectID,activity) %>% 
            summarise_each(funs(mean),
                           -group,-subjectID,-activity) %>%
            arrange(subjectID)
}
# 7.0 Run function sequence ----
source_Assignment();
read_Assignment_Data();
read_Label_Data();
map_descriptions();
append_Columns();
merge_Datasets();
filter_Variables();
extract_Data();


# 8.0 writes the metadata to file ----
Filename<-"metadataLog.txt"
write("\r\nSource metadata",Filename,append = TRUE)
write.table(sourceData$metadataLog$SourcePath,Filename,append = TRUE,col.name=FALSE)
write("\r\nSource data Location",Filename,append = TRUE)
write.table(sourceData$metadataLog$DataPath,Filename,append = TRUE,col.name=FALSE)
write("\r\nDownload Information",Filename,append = TRUE)
write.table(sourceData$metadataLog$DownLoadPath,Filename,append = TRUE,col.name=FALSE)

write("\r\nSource Observation Content",Filename,append = TRUE)
write.table(sourceData$metadataLog$content,Filename,row.name=FALSE,append = TRUE,col.name=FALSE)
write("\r\nSource Labels Lookup Content",Filename,append = TRUE)
write.table(sourceData$metadataLog$labelSource,Filename,row.name=FALSE,append = TRUE,col.name=FALSE)
write("\r\n Label Transformation Sample",Filename,append = TRUE)
write("Original",Filename,append = TRUE)
write.table(sourceData$metadataLog$sample,Filename,row.name=FALSE,append = TRUE,col.name=FALSE)
write("Transformed",Filename,append = TRUE)
write.table(sourceData$metadataLog$sampleRename,Filename,row.name=FALSE,append = TRUE,col.name=FALSE)

# 8.1 writes the tidydata to file----
write.table(transformData$full,"transformData.txt",row.name=FALSE)

# 8.2 writes the tidydata to file----
write.table(tidyData,"tidyData.txt",row.name=FALSE)

# 9.0 cleanup ----


rm(list= ls(envir=as.environment(globalenv()))[!(ls(envir=as.environment(globalenv())) %in% GlobalEnvKeep )],
   envir=as.environment(globalenv()))

#removes the function run_analysis
if(exists("run_analysis")){
rm(run_analysis,envir=as.environment(globalenv()))
}

# 9.9 Returns----

message("\r\nLicense:\r\n========
Use of this dataset in publications must be acknowledged by referencing the following publication [1] 
        
        [1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012
        This dataset is distributed AS-IS and no responsibility implied or explicit can be addressed to the authors or their institutions for its use or misuse. Any commercial use is prohibited.
        Jorge L. Reyes-Ortiz, Alessandro Ghio, Luca Oneto, Davide Anguita. November 2012.")

print("The results for the assignment have been summarised into a single dataframe in the variable called 'tidyData' and saved to the file 'tidyData.txt'. 
      Meta data and merged data have been saved to 'metadataLog.txt' and 'transformData.txt'.")
print("The principles of tidy data are:")
print(c("Each measured variable is in one column.","Each observation of that variable is in one row."," One table for each kind of variable. - In this assignmment each subject could be split to its own table"))
}
