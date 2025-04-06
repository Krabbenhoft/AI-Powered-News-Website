#!/usr/bin/python3
import pytumblr
import sys

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

response = client.create_text(
    blog_name,
    state="published",
    body= sys.argv[1]
)

if response:
    print ("done")