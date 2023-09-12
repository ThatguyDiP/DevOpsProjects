#!/bin/bash

# Display current directory

echo "Curent directory: $PWD"

#Create a new directory

echo "Creating a new Directory..."
mkdir my_directory
echo "New Directory Created."

# Change to new directory

echo "Changing to new directory..."
cd my_directory
echo "Current directory: $PWD"

# Create some files

echo "Creating Files..."
touch file1.txt
touch file2.txt
echo "Files Created."

# List files in the current directory

echo "Files in the current directory are..."
ls

# Move one level up
echo "Moving up one level..."
cd ..
echo "Current Directory: $PWD"

#Remove the new directory and its contents

echo "Removing the new directory, and its contents..."
rm -rf my_directory
echo "Directory Removed"

# List files in current directory
echo " Files in the current directory: "
ls

