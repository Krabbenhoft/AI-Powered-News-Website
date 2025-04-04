#!/bin/bash

# --- Configuration ---
SEARCH_QUERY="stock market today"
# Simple URL encoding for spaces (sufficient for this query)
ENCODED_QUERY=$(echo "$SEARCH_QUERY" | sed 's/ /+/g')

# --- IMPORTANT: CHOOSE YOUR SOURCE ---
# Option 1: Scrape links directly from a specific site (like the original script did)
SOURCE_URL="https://www.npr.org" # Using HTTPS now
FETCH_DESCRIPTION="links from $SOURCE_URL"

# Option 2: Actually perform a Google Search (UNCOMMENT the lines below to use this)
# GOOGLE_SEARCH_URL="https://www.google.com/search?q=${ENCODED_QUERY}&hl=en" # Use hl=en for English results
# SOURCE_URL="$GOOGLE_SEARCH_URL"
# FETCH_DESCRIPTION="Google search results for '$SEARCH_QUERY'"
# --- End Source Choice ---


USER_AGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36" # Be a polite bot

echo "Step 1: Fetching $FETCH_DESCRIPTION..."

# --- Step 1: Get Links from the Source URL using lynx ---
# Use lynx -dump to get text, -listonly to get a list of links,
# -nonumbers to simplify parsing, and provide a user agent.
# Pipe through awk to format and filter URLs properly.
# The awk script looks for lines starting with http/https and excludes google.com domains.
# Added error handling for the initial lynx fetch
search_results_text=$(lynx -dump -listonly -nonumbers -useragent="$USER_AGENT" "$SOURCE_URL" 2>/dev/null)

if [ -z "$search_results_text" ]; then
  echo "Error: Failed to fetch initial links from $SOURCE_URL or no links found."
  exit 1
fi

# Optional Debugging: Show raw links fetched
# echo "--- Raw Links Found ---"
# echo "$search_results_text"
# echo "--- End Raw Links ---"
# echo ""


# Corrected mapfile command:
# 1. Removed '$' from sitesReturned
# 2. Moved 'echo ""' which was causing the error (it's not needed here anyway)
# 3. Reads lines from the pipeline into the 'sitesReturned' array
mapfile -t sitesReturned < <(echo "$search_results_text" | awk '/^[[:space:]]*https?:\/\//{print $1}' | grep -ivE 'google\.com|google\.org|schema\.org' | sort -u)
# Note: Added google.org and schema.org to the filter as they often appear in search results / site maps

echo ""
echo "Found ${#sitesReturned[@]} unique relevant URLs."

# Optional Debugging: Show filtered URLs
# echo "--- Filtered URLs ---"
# if [ ${#sitesReturned[@]} -gt 0 ]; then
#   printf "%s\n" "${sitesReturned[@]}"
# else
#   echo "No URLs after filtering."
# fi
# echo "--- End Filtered URLs ---"
# echo ""


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
      output_file="file${count}"

      echo "  Fetching (${count}/${#sitesReturned[@]}): $url  -->  $output_file"

      # Use lynx -dump for the specific URL
      # Redirect stderr to /dev/null to suppress connection errors shown on the terminal
      # Check the exit status of lynx
      if lynx -dump -useragent="$USER_AGENT" "$url" >> "allnews.txt" 2>/dev/null; then
          # Check if the created file is empty (could indicate redirect issue or empty page)
          if [ ! -s "$output_file" ]; then
              echo "  Warning: Fetched URL '$url' but '$output_file' is empty. It might be a redirect or blank page."
              # Optional: remove empty file
              rm -f "$output_file" # Remove empty file to avoid confusion
          else
              echo "  Successfully created $output_file"
              ((processed_count++))
          fi
      else
          fetch_exit_status=$?
          echo "  Warning: Failed to fetch content from $url (Exit Status: $fetch_exit_status). Skipping."
          # Optional: remove potentially partially created file on error
          rm -f "$output_file"
      fi

      # Increment the counter for the next file name
      ((count++))

      # Optional: Add a small delay to be polite to servers
      # sleep 1
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


./ai.py

git add .
git commit -m "update for today's news"
git push