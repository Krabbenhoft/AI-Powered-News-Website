#!/usr/bin/python3
import pytumblr
import sys
from bs4 import BeautifulSoup

#simplified version of ai made script
basic_public = open("basic_public.txt").read().strip()
basic_private = open("basic_private.txt").read().strip()
auth_public = open("auth_public.txt").read().strip()
auth_private = open("auth_private.txt").read().strip()
blog_name = 'textdata'
print(basic_public, end="")

client = pytumblr.TumblrRestClient(
    basic_public,
    basic_private,
    auth_public,
    auth_private
)

print("Making post")

inputString = BeautifulSoup(sys.argv[1], "html.parser")
mainHeader = inputString.find_all("h1")[0]
response = client.create_text(
    blog_name,
    state="published",
    body= "Check out today's news at <a href=\"https://news-kohl-tau.vercel.app/\">Ai News App</a>! Just updated! Here is a snippet of what to expect:" + str(mainHeader)
)

if response:
    print ("done")