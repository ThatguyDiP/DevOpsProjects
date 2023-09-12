#!/bin/bash

# Create three files
echo "Creating Files...."
echo
echo "This is file 3" > file3.txt
echo
echo "This is file 1" > file1.txt
echo
echo "This is file 2" > file2.txt
echo
echo "FILES CREATED"
echo
echo
# Display files in their current order
echo "Files in their current order:"
ls
echo
echo

# Sort files aplhabetically
echo "Sorting files Alphabetically..."
ls | sort > sorted_files.txt
echo
echo "FILES SORTED"

# Display the sorted files
echo
echo
echo  "Sorted Files:"
echo
cat sorted_files.txt

# Remove original files
echo
echo
echo "Removing original Files..."
rm file1.txt file2.txt file3.txt
echo
echo
echo "ORIGINAL FILES REMOVED"
echo

# Rename sorted file to a new more descriptive name

echo "Renaming sorted file..."
mv sorted_files.txt sorted_files_sorted_alphabetically.txt
echo
echo
echo "FILE RENAMED"
echo
echo

# Display the final sorted file

echo "Final Sorted File:"

cat sorted_files_sorted_alphabetically.txt


