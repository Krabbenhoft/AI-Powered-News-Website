#!/usr/bin/env python3

from google import genai
keyFile = open("aikey.txt")
indexFile = open("index.html", mode="w")
clientKey = keyFile.readlines()[0]
client = genai.Client(api_key=clientKey)
dataFile = open("allnews.txt", errors='ignore')
dataLines = open("file1").read() + open("file2").read() + open("file3").read() + open("file4").read() + open("file5").read()
print(dataLines)

aiPrompt = "Output a summary of recent news using this context. Format using HTML tags: " +dataLines

response = client.models.generate_content(
    model="gemini-2.0-flash", contents=aiPrompt
)
print(response.text)
indexFile.writelines(str(response.text))