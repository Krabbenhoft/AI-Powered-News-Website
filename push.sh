git add .
git commit -m "update for today's news"
PAT=$(< gitkey.txt)
echo $PAT
git push https://Krabbenhoft:$PAT@github.com/Krabbenhoft/news.git main

