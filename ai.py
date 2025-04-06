#!/usr/bin/env python3

from google import genai

def getTextFromFiles():
    pass

#Basic settup of files
keyFile = open("aikey.txt")
dataFile = open("allnews.txt", errors='ignore')
indexFile = open("index.html", mode="w")
clientKey = keyFile.readlines()[0]
client = genai.Client(api_key=clientKey)

dataLines = open("textinput/file1").read() + open("textinput/file2").read() + open("textinput/file3").read() + open("textinput/file4").read() + open("textinput/file5").read()

print(dataLines)

#Get the text
aiPrompt = "Output a summary of recent news using this context. Format using HTML tags: " +dataLines
response = client.models.generate_content(
    model="gemini-2.0-flash", contents=aiPrompt
)
print(response.text)
indexFile.writelines(str(response.text))