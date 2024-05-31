#!/bin/bash

# Define the target directory
target_directory="$actionWorkspacePath/static/memos"
#LOCAL
#target_directory="$actionWorkspacePath/static/memos"

# Change to the target directory
cd "$target_directory"

# Verify that the directory change was successful
if [ $? -ne 0 ]; then
    echo "Failed to change to directory $target_directory"
    exit 1
fi

oldFolder="$1"
newFolder="$2"

if [ -d "$oldFolder" ]; then
  if [ -d "$newFolder" ]; then
    cp -R "$oldFolder/"* "$newFolder/"
    rm -r "$oldFolder"
  else
    mv "$oldFolder" "$newFolder"
  fi
else
  echo "Folder $oldFolder does not exist."
fi
