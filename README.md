# IMAGEGEAR JAVA PDF v1 - by Accusoft

## SYSTEM REQUIREMENTS

Before installing **ImageGear Java PDF**, make sure your computer meets the following minimum requirements:

  * 64-bit Intel-based Linux platform
  * Java Development Kit (JDK) 8 or greater
  * Maven 3 or greater
  * Standard C Cibrary (libc) 2.14 or greater
 
## HOW TO INSTALL

1. Use the following commands to double check you have the appropriate versions of the system requirements:
  1. For Standard C Cibrary (**libc**), use the following: ```ldd --version```
  2. For Java Development Kit (**JDK**), use: ```java -version```
  3. For **Maven**, use: ```mvn -version```
2. Download the installation file **ImageGearJavaPDF_1.0_Linux64.tar.gz**
3. Move the installation file **ImageGearJavaPDF_1.0_Linux64.tar.gz** into your home directory **$HOME**
4. Extract the installation file contents, which is typically done by running: ```tar zxvf ImageGearJavaPDF_1.0_Linux64.tar.gz```
5. In the **$HOME/Accusoft/ImageGearJavaPDF1-64** folder after extracting, locate the **install.sh** script and run it as root user: ```sudo ./install.sh```
6. The script will search for and modify the current user's shell profile files to add some environment variables and attempt to run the Accusoft License Manager

## WHERE TO START | SAMPLES AND USER'S GUIDE
 
A good place to start is running one of our samples:
 
1. Open the Samples directory by running: **cd $HOME/Accusoft/ImageGearJavaPDF1-64/samples/**. All samples are located in this directory. We also include sample files you can use to test located in the sub-folder **SampleData**
2. Move to the directory for the **OpenSaveSample** by running: ```cd OpenSaveSample```
3. Let's compile the sample using Maven. Run: ```mvn package```
4. You can now run the sample using: ```java -jar ./target/OpenSaveSample-1.0.jar "../SampleData/Pdf/single-page.pdf" "single-page-output.pdf" TRUE```
5. Just just opened one of our sample PDF files and saved as a new PDF under the current folder (the last argument specifies that the PDF will be **LINEARIZED**)
6. For each sample you can also specify the ```-h``` command-line option, which will display an explanation of the different options available and how to use the sample
 
More samples are available in our **Samples** folder. Next, we recommend using our User's Guide. We have a **Getting Started** section that also includes a tutorial to create your first project using IG JAVA PDF. Find the User's Guide by running: ```cd $HOME/Accusoft/ImageGearJavaPDF1-64/help/```
 
## HOW TO GET HELP

Questions? You can get technical support by:

* Visit our website at https://www.accusoft.com/support/
* Call (813) 875-7575
