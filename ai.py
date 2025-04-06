#!/usr/bin/env python3

from google import genai
import os.path
import codecs

def checkUTF(fileName):
    try:
        currentFile = codecs.open(fileName, encoding='utf-8', errors='strict')
        for line in currentFile:
            pass
        return True
    except:
        return False


def getTextFromFiles():
    outputString = ""
    for i in (range(1,1000)):
        fileName = f"textinput/file{i}.txt"
        if(not os.path.isfile(fileName)):
            print(fileName, " is bad error!")
            break
        elif (not checkUTF(fileName)):
            print(fileName, " is not UTF-8")
        else:
            outputString += open(fileName).read()
            print("File is good and is: " + str(i))
    return outputString

print(checkUTF("indesx.html"))
print(getTextFromFiles())
# #Basic settup of files
# keyFile = open("aikey.txt")
# indexFile = open("index.html", mode="w")
# clientKey = keyFile.readlines()[0]
# client = genai.Client(api_key=clientKey)

# dataLines = open("textinput/file2.txt").read() + open("textinput/file3.txt").read() + open("textinput/file4.txt").read() + open("textinput/file5.txt").read()
# getTextFromFiles()
# print(dataLines)

# #Get the text
# aiPrompt = "Output a summary of recent news using this context. Format using HTML tags: " +dataLines
# response = client.models.generate_content(
#     model="gemini-2.0-flash", contents=aiPrompt
# )
# print(response.text)
# indexFile.writelines(str(response.text))