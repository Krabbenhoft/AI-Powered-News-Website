#!/usr/bin/env python3

from google import genai
import os.path
import codecs
import re
import datetime

def checkUTF(fileName):
    try:
        currentFile = codecs.open(fileName, encoding='utf-8', errors='strict')
        for line in currentFile:
            pass
        return True
    except:
        return False

#this breaks once you get to an invalid file
def getTextFromFiles():
    outputString = ""
    badSite = ""
    for i in (range(1,1000)):
        fileName = f"textinput/file{i}.txt"
        if(not os.path.isfile(fileName)):
            print(fileName, " is bad error!")
            badSite = fileName
            break
        elif (not checkUTF(fileName)):
            print(fileName, " is not UTF-8")
        else:
            outputString += open(fileName).read()
            print("File is good and is: " + str(i))
    return (outputString + "Bad site is: " + badSite)

def cleanTextFromFiles(inputText):
    returnString = ""
    fileArray = inputText.split("\n")
    print(fileArray)
    for line in fileArray:
        if (not re.search(r'([\[\]\(\)\\\/\+\*]|http|www|\d\.)', line)):
            print("Current match: ", re.search(r'([\[\]\(\)\\\/\+\*\_\>\<\&]|http|www|\d\.)', line))
            returnString += line
    return returnString

#Basic settup of files
keyFile = open("aikey.txt")
indexFile = open(str(datetime.date.today()) + ".html", mode="w")
clientKey = keyFile.readlines()[0]
client = genai.Client(api_key=clientKey)

dataLines = (cleanTextFromFiles(getTextFromFiles()))
getTextFromFiles()
print(dataLines)

#Get the text
aiPrompt = """Output a summary of recent news using this context. It should be a very verbose summary of the news
that explains all of the important things happening. Don't include random 'interest' pieces, but only the important
stuff. Include historical background if nessesary to make a very important but brief news item longer.
Format using HTML tags. Make sure the first h1 element contains a meaningfull description of the day's news. """ +dataLines
response = client.models.generate_content(
    model="gemini-2.0-flash", contents=aiPrompt
)
print(response.text)
indexFile.writelines(str(response.text)[8:len(str(response.text))-23])
print(datetime.date.today())