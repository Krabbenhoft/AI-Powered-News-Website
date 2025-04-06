#!/bin/bash
#configure folder
rm -r textinput
mkdir textinput

#read in results into an an array split_results
search_results=$(lynx -dump -listonly -nonumbers "https://www.google.com/search?q=stock_market_news_today")
split_results=(${search_results// /})

#read the reults with propor parsing
#make an empty array to read to and varaible to track the index
modifiedResults=$()
modifiedCounter=0

#loop over all of the returned search results
for element in "${split_results[@]}"; do

  #only work on aucutal serach results
  if grep -q "https://www.google.com/url?q=" <<< $element ; then

    #remove google beggining
    baseWord="${element:29}"

    #removing google ending - everything after the first &
    modifiedResults[$modifiedCounter]=${baseWord%%\&*}
    ((modifiedCounter++))
    fi
done
echo "${modifiedResults[@]}"

#get the search results
returnedCounter=0

#download every URL
for current_url in "${modifiedResults[@]}"; do
  echo "Currently scraping: $current_url to file textinput/file${returnedCounter}.txt"
  timeout 10s lynx -dump --read_timeout=10 --connect_timeout=10 "$current_url" >> "textinput/file${returnedCounter}.txt"
  ((returnedCounter++))
done

#Generate and push the text after ai interpolation
./ai.py
git add .
git commit -m "update for today's news"
PAT=$(< gitkey.txt)
echo $PAT
git push https://Krabbenhoft:$PAT@github.com/Krabbenhoft/news.git main