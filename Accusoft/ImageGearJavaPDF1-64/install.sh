#!/bin/bash
share_dst=`/bin/pwd`
lib_dst=$share_dst"/lib"
resource_dst=$share_dst"/resource"
version="1.0-1.0.251"
path_to_local_repo=$share_dst"/repository"
installed_file_list=$share_dst"/installer/files.list"
home_path=$(eval echo "~"$(logname))
path_to_user_home_files=$home_path"/ImageGearJavaPDF"
profile_d_script=/etc/profile.d/ig_java_pdf_env.sh
export PATH=${M2_HOME}/bin:${PATH}

# ImageGearJavaPDF installation folder structure 
#	usr/lib for all .so and related shared libraries and links.
#	usr/share/ImageGearJavaPDF/
#		docs for html documentation
#		java for jar files
#		samples for samples
#		licensing for license manager
#
# Defined new environment variables 
#	IG_JAVA_PDF_REPOSITORY - path to the component Maven repository. 

#detect system environment condition
function detect_system(){
	detect_system_for_native
	detect_system_for_java
}

#detect system environment condition for native libraries
function detect_system_for_native(){
		
	#Determine Unix OS (AIX  HP-UX  Linux  Solaris)
	[ -z "${UNAME:-}" ]      && UNAME=`(uname) 2>/dev/null`
	[ -z "${UNAME:-}" -a -d /sys/node_data ] && UNAME="DomainOS"
	[ -z "${UNAME:-}" ]      && (echo could not determine hosttype ; exit)
	#Determine Architecture
	ARCH=`(uname -m) 2>/dev/null`

	if [ "$UNAME" = "SunOS" ] ; then
	  MACHINE="Solaris"
	elif [ "$UNAME" = "Linux" ] ; then
	  if [ "$ARCH" = "ppc64" ] || [ "$ARCH" = "ppc" ] ; then
		echo $UNAME is not supported yet
		exit
	  else
		MACHINE="Linux"
	  fi
	else
	  echo $UNAME is not supported yet
	  exit
	fi

	if [ "$MACHINE" = "HP-UX-IA" ] || [ "$MACHINE" = "HP-UX" ] || [ "$MACHINE" = "LinuxPPC" ]; then
		echo Please contact sales@accusoft.com to inquire about installing ImageGearJavaPdf for ${UNAME}
		exit
	fi
	
}

#detect system environment condition for java
function detect_system_for_java(){
			
	if [ $(is_maven_installed) != "true" ]; then
		echo Maven required for ImageGearJavaPDF. Please install Maven and repeat installation.
		exit
	fi
	
	if [ $(is_java_installed) != "true" ]; then
		echo JDK 8 required for ImageGearJavaPDF. Please install JDK 8 or greater and repeat installation.
		exit
	fi

	if [ $(is_having_internet_connection) != "true" ]; then
		echo Maven required internet connection for downloading artifacts. Please enable internet connection and repeat installation.
		exit
	fi

}

# Check is maven installed on system
function is_having_internet_connection(){
	output=$(wget -q --tries=10 --timeout=20 --spider http://google.com)
	if [ $? -eq 0 ]; then
		echo "true"
	else
		echo "false"
	fi
}

# Check is maven installed on system
function is_maven_installed(){
	output=$(mvn --version)
	if [ $? -eq 0 ]; then
		echo "true"
	else
		echo "false"
	fi
}

# Check is java installed on system
function is_java_installed(){	
	if [ $(type -p java) ]; then
		java_exists="java"
	elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then
		java_exists="$JAVA_HOME/bin/java"	
	fi
	if [ $java_exists ]; then
		version=$("$java_exists" -version 2>&1 | awk -F '"' '/version/ {print $2}')		
		v_major="$(echo "$version"  | awk -F'.' '{print $1}')"
		v_minor="$(echo "$version"  | awk -F'.' '{print $2}')"
		
		if [ $v_major -ge 1 ] && [ $v_minor -ge 8 ] ; then
			echo "true"
		else         
			echo "false"
		fi
	else
		echo "false"
	fi
	 
}

# Check is java installed on system
function is_ig_java_pdf_installed(){
	if [ -e $share_dst ]
		then
			echo "true"
		else
			echo "false"
	fi
}

# Check is latest operation faled and exit with prompting a message
function check_no_errors(){
  if [ $? -ne 0 ]
	then
		echo $1
		exit 1
  fi
}

# Check is latest operation faled and prompting a message
function check_no_warnings(){
  if [ $? -ne 0 ]
	then
		echo $1
  fi
}


#Modifies a profile file to add/replace imagegear definitions
function modify_profile()
{
	if [ $# -ge 1 ] ; then
		if [ -f $@ ] ; then
			#backup existing profile and remove any previous imagegear settings
			cp $@ ${@}.bk
			if [ $MACHINE = "AIX" ] ; then
			  cat ${@}.bk | \
			  grep -v "IG_JAVA_PDF" > $@
			else
			  cat ${@}.bk | \
			  grep -v "IG_JAVA_PDF" > $@
			fi
		fi

		echo "IMAGE_GEAR_LIBRARY_PATH="$lib_dst" #IG_JAVA_PDF" >> $@
		echo "ACCUSOFT_LICENSE_DIR="$home_path"/.config/accusoft/licensing #IG_JAVA_PDF" >> $@
		echo "IMAGE_GEAR_PDF_RESOURCE_PATH="$resource_dst"/PDF/ #IG_JAVA_PDF" >> $@
		echo "IMAGE_GEAR_PS_RESOURCE_PATH="$resource_dst"/PS/ #IG_JAVA_PDF" >> $@
		echo "IMAGE_GEAR_HOST_FONT_PATH="$resource_dst"/PS/Fonts/ #IG_JAVA_PDF" >> $@
		echo "SSMPATH="$lib_dst" #IG_JAVA_PDF" >> $@
		echo "export IMAGE_GEAR_LIBRARY_PATH ACCUSOFT_LICENSE_DIR #IG_JAVA_PDF" >> $@
		echo "export IMAGE_GEAR_PDF_RESOURCE_PATH IMAGE_GEAR_PS_RESOURCE_PATH IMAGE_GEAR_HOST_FONT_PATH SSMPATH #IG_JAVA_PDF" >> $@
		echo "IMAGE_GEAR_JAVA_PDF_REPOSITORY=file:"$path_to_local_repo" #IG_JAVA_PDF">> $@  
		echo "export IMAGE_GEAR_JAVA_PDF_REPOSITORY #IG_JAVA_PDF" >> $@
		echo "LD_PRELOAD=\${LD_PRELOAD}:"$lib_dst"/libIGCORE18.so #IG_JAVA_PDF" >> $@
		echo "LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:"$lib_dst" #IG_JAVA_PDF" >> $@
		echo "export LD_PRELOAD LD_LIBRARY_PATH #IG_JAVA_PDF" >> $@

	fi
}

#Modifies a profile file to remove imagegear definitions
function clean_up_profile()
{
	if [ $# -ge 1 ] ; then
		if [ -f $@ ] ; then
			#backup existing profile and remove any previous imagegear settings
			cp $@ ${@}.bk
			if [ $MACHINE = "AIX" ] ; then
			  cat ${@}.bk | \
			  grep -v "IG_JAVA_PDF" > $@
			else
			  cat ${@}.bk | \
			  grep -v "IG_JAVA_PDF" > $@
			fi
		fi
	fi
}

# Set environment variables
function clean_up_env(){
	PROFILE_FOUND="false"
	echo "Searching for profiles to modify"
	if [ -f $home_path/.bashrc ] ; then
		BASH_FILE=$home_path/.bashrc
		clean_up_profile $BASH_FILE
		echo " Modified profile: $BASH_FILE"
		PROFILE_FOUND="true"
	fi
	
	if [ -f $home_path/.profile ] ; then
	   clean_up_profile $home_path/.profile
	   echo " Modified profile: $home_path/.profile"
	   PROFILE_FOUND="true"
	fi
	if [ -f $home_path/.cshrc ] ; then
	   clean_up_profile $home_path/.cshrc
	   echo " Modified profile: $home_path/.cshrc"
	   PROFILE_FOUND="true"
	fi
	if [ -f $home_path/.tcshrc ] ; then
	   clean_up_profile $home_path/.tcshrc
	   echo " Modified profile: $home_path/.tcshrc"
	   PROFILE_FOUND="true"
	fi
}


# Set environment variables
function set_env(){
	PROFILE_FOUND="false"
	echo "Searching for profiles to modify"
	if [ -f $home_path/.bashrc ] ; then
		BASH_FILE=$home_path/.bashrc
		modify_profile $BASH_FILE
		echo " Modified profile: $BASH_FILE"
		PROFILE_FOUND="true"
	fi
	
	if [ -f $home_path/.profile ] ; then
	   modify_profile $home_path/.profile
	   echo " Modified profile: $home_path/.profile"
	   PROFILE_FOUND="true"
	fi
	if [ -f $home_path/.cshrc ] ; then
	   modify_profile $home_path/.cshrc
	   echo " Modified profile: $home_path/.cshrc"
	   PROFILE_FOUND="true"
	fi
	if [ -f $home_path/.tcshrc ] ; then
	   modify_profile $home_path/.tcshrc
	   echo " Modified profile: $home_path/.tcshrc"
	   PROFILE_FOUND="true"
	fi

	modify_profile $profile_d_script
	echo " Modified profile: "$profile_d_script
	PROFILE_FOUND="true"
	
	
	if [ $PROFILE_FOUND != "true" ] ; then
		echo "Failed to find any user shell profiles: $PROFILE_FOUND"
		echo "Where is your shell profile file?:"
		read PROFILE_INPUT
		if ( [ $PROFILE_INPUT != "" ] && [ -f $PROFILE_INPUT ] ) ; then
				modify_profile $PROFILE_INPUT
			else
				echo "File does not exist, no profile modified"
				echo "You should add the following lines to some script executed on login:"
				echo "IMAGE_GEAR_LIBRARY_PATH="$lib_dst 
				echo "ACCUSOFT_LICENSE_DIR="$home_path"/.config/accusoft/licensing" 
				echo "IMAGE_GEAR_PDF_RESOURCE_PATH="$resource_dst"/PDF/"
				echo "IMAGE_GEAR_PS_RESOURCE_PATH="$resource_dst"/PS/"
				echo "IMAGE_GEAR_HOST_FONT_PATH="$resource_dst"/PS/Fonts/"
				echo "SSMPATH="$lib_dst
				echo "export IMAGE_GEAR_LIBRARY_PATH ACCUSOFT_LICENSE_DIR"
				echo "export IMAGE_GEAR_PDF_RESOURCE_PATH IMAGE_GEAR_PS_RESOURCE_PATH IMAGE_GEAR_HOST_FONT_PATH SSMPATH"
				echo "IG_JAVA_PDF_REPOSITORY=file:"$path_to_local_repo
				echo "LD_PRELOAD=\${LD_PRELOAD}:"$lib_dst"/libIGCORE18.so"
				echo "LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:"$lib_dst
				echo "export LD_PRELOAD LD_LIBRARY_PATH"

		fi
	fi
	
}

# Install software to the system
function install(){	
  #detect system and exit if error
  detect_system  
  echo "Installing ImageGearJavaPDF. Version - "$version
    	
  # install libraries
  if ! [ $(id -u) = 0 ]; then
	echo "Root access required!"
	sudo $0 install_libs
  else
	install_libs
  fi
  
  #set env for this shell
  export IMAGE_GEAR_LIBRARY_PATH=$lib_dst 
  export ACCUSOFT_LICENSE_DIR=$home_path"/.config/accusoft/licensing" 
  export IMAGE_GEAR_PDF_RESOURCE_PATH=$resource_dst"/PDF/"
  export IMAGE_GEAR_PS_RESOURCE_PATH=$resource_dst"/PS/"
  export IMAGE_GEAR_HOST_FONT_PATH=$resource_dst"/PS/Fonts/"
  export SSMPATH=$lib_dst
  export IMAGE_GEAR_JAVA_PDF_REPOSITORY="file:"$path_to_local_repo
  export LD_PRELOAD=$LD_PRELOAD":"$lib_dst"/libIGCORE18.so"
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH":"$lib_dst
  
  # Create local maven repository entry for IG Java PDF jar 
  install_repo  
  
  # Run license manager
  install_licensing
  
  
  echo
  echo "Please explore product folders:"
  echo "     "$share_dst
  echo "For samples, documentation and sample images"
  echo "Done!"
  
  
}


# Install libraries to the system
# Note: root access requered
function install_libs(){	  
  # install libraries
  echo "Installing libraries..."    
  echo $lib_dst>>/etc/ld.so.conf.d/lib_ig_java_pdf.conf
  check_no_errors "Errors occurred installing libraries"
    
  # Create sym link to the libIGPDF18 if /usr/lib64 exists
  if [ -e /usr/lib64 ]; then
	ln -sf $lib_dst"/libIGPDF18.so" /usr/lib64/libIGPDF18.so  
	ln -sf $lib_dst"/libIgPdf.so.1.0.251" /usr/lib64/libIgPdf.so.1
	ln -sf /usr/lib64/libIgPdf.so.1 /usr/lib64/libIgPdf.so
  fi  

  ldconfig
  check_no_errors "Errors occurred installing libraries"

  # Set environment variables
  echo "Setting environment variables"
  set_env
  
}

# Prepare and run license manager
function install_licensing(){	
  # Run license manager
  echo "Launching AccuSoft License Manager"
  license_manager_jar_file=$share_dst"/licensing/licensemanager/licensemanager.jar"
  java -jar $license_manager_jar_file
  ALMRETURN=$?
  if [ $ALMRETURN != 0 ] ; then
	echo "AccuSoft License Manager failed to run. Oracle JDK 8+ and X server are required"
  fi
  echo
  echo "You can run the License Manager later by running:"
  echo "java -jar "$license_manager_jar_file
  echo
  echo "You can also run the License Manager in command line mode"
      
}

# Create and prepare local repository
function install_repo(){	
  # Create local maven repository entry for our jar 
  echo "Creating local maven repository entry for IgPdf.jar"
  jar_file=$share_dst"/java/IgPdf.jar" 
  groupId="com.accusoft"
  artifactId="ImageGearPDFJava"		  
  if [ ! -d $path_to_local_repo ]; then
	mkdir $path_to_local_repo
  fi
  ret=$(mvn install:install-file -Dfile=$jar_file -DgroupId=$groupId -DartifactId=$artifactId -Dversion=1.0 -Dpackaging=jar -DgeneratePom=true -DlocalRepositoryPath=$path_to_local_repo)
  check_no_errors "Errors occurred creating local Maven repository entry for IgPdf.jar\r\n"$ret		
  
}


#remove software from system
function remove(){
  echo "Removing ImageGearJavaPDF"
  
  detect_system_for_native
  
  if [ -e /etc/ld.so.conf.d/lib_ig_java_pdf.conf ]; then
	rm /etc/ld.so.conf.d/lib_ig_java_pdf.conf
	check_no_errors "Errors occurred uninstalling libraries"
  fi
 
  if [ -e $profile_d_script ]; then
	  rm $profile_d_script 
	  check_no_errors "Errors occurred uninstalling libraries"
  fi
  
  # Remove sym link to the libIGPDF18 if /usr/lib64 exists
  if [ -e /usr/lib64 ]; then
	rm /usr/lib64/libIGPDF18.*
	rm /usr/lib64/libIgPdf.*
  fi
          
  # Run ld config for creating symbol links for new libraries
  echo "Updating symbol links"
  ldconfig  
  check_no_warnings "Errors occurred updating symbol links"
  
  # Clean up environment variables
  echo "Clean up environment variables"
  clean_up_env
  
  # Remove product folder
  echo "Remove product folder"
  rm -rf $share_dst

  # Test Accusoft folder is empty and remove it if possible
  if [ ! "$(ls -A ../../Accusoft)" ]; then  
	rm -rf ../../Accusoft
  fi
    
  echo "Done!" 
}

#check number of parameters 
if [ $# -eq 0 ]
	then
		install  
	else
		if [ $1 == "install" ]; then
				install				
		elif [ $1 = "install_libs" ]; then
			detect_system_for_native
			install_libs
		elif [ $1 = "remove" ]; then
			if ! [ $(id -u) = 0 ]; then
				echo "Root access required!"
				sudo $0 remove
			else
				remove
			fi  
		else
			echo "Welcome to ImageGearJavaPDF install script. version - "$version
			echo "Usage:"
			echo "	install - install ImageGearJavaPDF"
			echo "	remove - remove ImageGearJavaPDF"  
		fi			
fi

unset create_sym_links
unset detect_system_for_native
unset detect_system_for_java
unset install_repo
unset install_licensing
unset install_libs
unset clean_up_env
unset clean_up_profile
unset detect_system
unset remove
unset install
unset set_env
unset modify_profile
unset check_no_warnings
unset detect_system
unset is_maven_installed
unset is_java_installed
unset check_no_errors
