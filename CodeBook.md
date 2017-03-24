# CodeBook

## Data

### Description
The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data.

### output R Data dataframes
`assignmentData`: is the R variable that is produced when [`loadAssignment()`](https://github.com/JulesBuh/CleaningData/blob/master/CodeBook.md#functions) function is run. It contains a dataframe that is the result of merging the train and test datasets, see Transformations section below for a description of functions that process the source data into this dataframe.

`assignmentData_FullVarSet`: is the R variable that is produced before the means and std extract is applied

`assignmentData_bySubject`: is the R variable that is produced when [`tidyExtract()`](https://github.com/JulesBuh/CleaningData/blob/master/CodeBook.md#functions) function is run. it contains a dataframe that is the result of extracting and summarising the data and summarises the average of each variable for each subject.

`assignmentData_byActivity`: is the R variable that is produced when [`tidyExtract()`](https://github.com/JulesBuh/CleaningData/blob/master/CodeBook.md#functions) function is run. it contains a dataframe that is the result of extracting and summarising the data and summarises the average of each variable for each activity.

### Reference 
The source data was downloaded from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

See the README.txt in the [link to the zip folder](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) for a fuller explanation of the dataset source files.

[1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012
 
## Variables

In addition to the source file variables which can be found within the features.txt and features_info.txt of the [source data](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip), 3 additional variable are created as a result of the transformation described below:

 `group`:   Defines the dataset from which the record came from {values: `test`,`train`}
 
 `activity`: Displays the written label for the observation rather than the index which was provided in ./`group`/y_`group`.txt
 
 `subjectID`: Displays that the data which was provided in ./[group]/subject_[group].txt
 
## Transformations

### Software

    platform       x86_64-w64-mingw32          
    arch           x86_64                      
    os             mingw32                     
    system         x86_64, mingw32             
    major          3                           
    minor          3.2                         
    year           2016                        
    month          10                          
    day            31                          
    svn rev        71607                       
    language       R                           
    version.string R version 3.3.2 (2016-10-31)

### sourceCode
['run_analysis.R`](https://github.com/JulesBuh/CleaningData/blob/master/run_analysis.R) is the file which contains the assignment function
#### Functions
`loadassignment()`: - This performs the datagrab from the source and processes it to produce the [`assignmentData`](https://github.com/JulesBuh/CleaningData/blob/master/CodeBook.md#output-r-data-dataframes) dataframe. During this function, the fuller data set with all variables is also saved to the variable  [`assignmentData_FullVarSet`](https://github.com/JulesBuh/CleaningData/blob/master/CodeBook.md#output-r-data-dataframes)
it is made up of 4 internal functions:      

   [sourceAssignment()](https://github.com/JulesBuh/CleaningData/blob/master/run_analysis.R#L25):     obtains the data from the download link
   [readAssignmentData()](https://github.com/JulesBuh/CleaningData/blob/master/run_analysis.R#L92):   reads the observation data from multiple txt files
   [readLabelData()](https://github.com/JulesBuh/CleaningData/blob/master/run_analysis.R#L196):  reads the label data from multiple txt files
   [assignLabelDescriptions()](https://github.com/JulesBuh/CleaningData/blob/master/run_analysis.R#L292):    performs operations on the data to assign labels and variable names and the merge and extract std() and mean() variables from the full dataset

`tidyExtract()`: - This performs average by subject and activty for each variable and creates a duplicate dataframe called [`assignmentData_bySubject`](https://github.com/JulesBuh/CleaningData/blob/master/CodeBook.md#output-r-data-dataframes) and [`assignmentData_byActivity`](https://github.com/JulesBuh/CleaningData/blob/master/CodeBook.md#output-r-data-dataframes)
     
For more information read the comments in the [run_analysis.R script](https://github.com/JulesBuh/CleaningData/blob/master/run_analysis.R)
##### Function Structure
Each function within the script is structured as follows:

    # Section
   [- Description](https://github.com/JulesBuh/CleaningData/blob/master/run_analysis.R#L6)
   [0 Dependencies and Input validation](https://github.com/JulesBuh/CleaningData/blob/master/run_analysis.R#L20)
   [1 Function Body](https://github.com/JulesBuh/CleaningData/blob/master/run_analysis.R#L23)
   [1.#   Sub step demarcation](https://github.com/JulesBuh/CleaningData/blob/master/run_analysis.R#L25)
    ...
   [9     Returns demarcation](https://github.com/JulesBuh/CleaningData/blob/master/run_analysis.R#L282)

### Notes
Some of the varibles in the [original source dataset](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) described in features.txt are not unique which conflicts with the `dplyr` functions.
To overcome this `make.unique()` is used on the this file after it is loaded and the ~~~ seperator is used follwed by a unique number.
To revert back to original names remove all characters including and following ~~~  

License:
========
Use of this dataset in publications must be acknowledged by referencing the following publication [1]

[1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012

This dataset is distributed AS-IS and no responsibility implied or explicit can be addressed to the authors or their institutions for its use or misuse. Any commercial use is prohibited.

Jorge L. Reyes-Ortiz, Alessandro Ghio, Luca Oneto, Davide Anguita. November 2012.

