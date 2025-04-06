#!/bin/bash

# --- Configuration ---
SEARCH_QUERY="stock market today"
# Simple URL encoding for spaces (sufficient for this query)
ENCODED_QUERY=$(echo "$SEARCH_QUERY" | sed 's/ /+/g')

#Option 2: Actually perform a Google Search (UNCOMMENT the lines below to use this)
GOOGLE_SEARCH_URL="https://www.google.com/search?q=${ENCODED_QUERY}&hl=en" # Use hl=en for English results
SOURCE_URL="$GOOGLE_SEARCH_URL"
FETCH_DESCRIPTION="Google search results for '$SEARCH_QUERY'"


echo "Step 1: Fetching $FETCH_DESCRIPTION..."

# --- Step 1: Get Links from the Source URL using lynx ---
# Use lynx -dump to get text, -listonly to get a list of links,
# -nonumbers to simplify parsing, and provide a user agent.
# Pipe through awk to format and filter URLs properly.
# The awk script looks for lines starting with http/https and excludes google.com domains.
# Added error handling for the initial lynx fetch
search_results_text=$(lynx -dump -listonly -nonumbers "$SOURCE_URL" 2>/dev/null)

if [ -z "$search_results_text" ]; then
	echo "Error: Failed to fetch initial links from $SOURCE_URL or no links found."
	exit 1
fi

# Corrected mapfile command:
# 1. Removed '$' from sitesReturned
# 2. Moved 'echo ""' which was causing the error (it's not needed here anyway)
# 3. Reads lines from the pipeline into the 'sitesReturned' array
mapfile -t sitesReturned < <(echo "$search_results_text" | awk '/^[[:space:]]*https?:\/\//{print $1}' | grep -ivE 'google\.com|google\.org|schema\.org' | sort -u)
# Note: Added google.org and schema.org to the filter as they often appear in search results / site maps

echo ""
echo "Found ${#sitesReturned[@]} unique relevant URLs."

# --- Step 2: Fetch Content for Each Filtered URL ---
count=1
processed_count=0
echo "Step 2: Fetching content for each URL..."

# Check if the array is empty before looping
if [ ${#sitesReturned[@]} -eq 0 ]; then
	echo "No URLs found to process after filtering."
else
	for url in "${sitesReturned[@]}"; do
			# Define the output filename
			output_file="textinput/file${count}.txt"

			echo "	Fetching (${count}/${#sitesReturned[@]}): $url	-->	$output_file"

			# Use lynx -dump for the specific URL
			# Redirect stderr to /dev/null to suppress connection errors shown on the terminal
			# Check the exit status of lynx
			if lynx -dump "$url" >> $output_file 2>/dev/null; then
					# Check if the created file is empty (could indicate redirect issue or empty page)
					if [ ! -s "$output_file" ]; then
							echo "	Warning: Fetched URL '$url' but '$output_file' is empty. It might be a redirect or blank page."
							# Optional: remove empty file
							rm -f "$output_file" # Remove empty file to avoid confusion
					else
							echo "	Successfully created $output_file"
							((processed_count++))
					fi
			else
					fetch_exit_status=$?
					echo "	Warning: Failed to fetch content from $url (Exit Status: $fetch_exit_status). Skipping."
					# Optional: remove potentially partially created file on error
			fi

			# Increment the counter for the next file name
			((count++))
 
      if (( $count == 50));
      then
        break
      fi
	done
fi

echo ""
echo "Script finished."
echo "Attempted to process ${#sitesReturned[@]} URLs."
echo "Successfully created $processed_count files."
# Adjust count for loop iteration if files were created
if (( processed_count > 0 )); then
	echo "Created files are named like: file1, file2, ..."
fi

#Generate and push the text after ai interpolation
./ai.py
git add .
git commit -m "update for today's news"
PAT=$(< gitkey.txt)
echo $PAT
git push https://Krabbenhoft:$PAT@github.com/Krabbenhoft/news.git main