#!/bin/bash

# Directory to store output files 
output_directory="/opt/asvalid"
base_path="/usr/local/bin/asvalid-tool"

# Create the output directory if it does not exist
mkdir -p "$output_directory"

version=$(asd --version | awk '{print $5}' )

asconfig convert --aerospike-version "$version" --output /opt/asvalid/aerospike.yaml /etc/aerospike/aerospike.conf
if [ $? -ne 0 ]; then
  echo "Failed to convert conf to yaml, see above"
  exit 1
fi

# Run yamlParser.py using Python interpreter
python3 $base_path/yamlParser.py
if [ $? -ne 0 ]; then
  echo "Failed to run yamlParser.py"
  exit 1
fi

# Run generateDynamicConf.py using Python interpreter
python3 $base_path/generateDynamicConf.py
if [ $? -ne 0 ]; then
  echo "Failed to run generateDynamicConf.py"
  exit 1
fi

# Run compareConfig.py using Python interpreter and capture its output
output=$(python3 $base_path/compareConfig.py)
if [ $? -ne 0 ]; then
  echo "Failed to run compareConfig.py"
  exit 1
fi

# # Display the output only if it is not empty
# if [ -n "$output" ]; then
echo "$output"

  # Save the output to a file
#   output_file="${output_directory}/$(date +"%Y-%m-%d_%H-%M-%S").txt"
#   echo "$output" > "$output_file"
#   echo "Output stored in $output_file"
# else
#   echo -n "No differences found between static and dynamic values"
# fi
