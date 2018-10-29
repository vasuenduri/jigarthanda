import json
import warnings
import urllib
import os
import time
import datetime
import boto3

from vars import *

def saveimage(event):
 import pymysql
 comicName = event['name']
 url = event['link']
 fullfilename = os.path.join('/tmp', comicName)
 image=urllib.URLopener()
 image.retrieve(url,fullfilename)
 try:
  s3_client = boto3.client('s3')
  s3_client.upload_file(fullfilename, bucket_name, comicName)
 except:
  output="Unable to upload the image to s3 bucket"
  return output
  exit()

 try:
   mydb = pymysql.connect(
   host=rds_host,
   user=rds_username,
   passwd=rds_password,
   database=rds_database
   )
   with warnings.catch_warnings():
    warnings.simplefilter("ignore")
    connect = mydb.cursor()
    connect.execute("CREATE TABLE IF NOT EXISTS images (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255) NOT NULL, link TEXT NOT NULL, path VARCHAR(255) NOT NULL, uploadtime TIMESTAMP NOT NULL DEFAULT    CURRENT_TIMESTAMP)")

   uploadpath=str(bucket_name)+"/"+str(comicName)
   ts = time.time()
   timestamp = datetime.datetime.fromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S')
   sql = "INSERT INTO images (name,link,path,uploadtime) VALUES (%s, %s, %s,%s);"
   val = (comicName, url, uploadpath,timestamp)
   connect.execute(sql, val)
   mydb.commit()
   mydb.close()
   output="Successfully Uploaded the image "+comicName+" to s3 bucket"
   return output
 except:
   output="Unable to save the image to database"
   return output
   exit()

def listimage(event):
 try:
  import pymysql
  mydb = pymysql.connect(
  host=rds_host,
  user=rds_username,
  passwd=rds_password,
  database=rds_database
  )
  connect = mydb.cursor()
  sql = "SELECT * FROM images"
  connect.execute(sql)
  data = connect.fetchall ()
  global fullfilename
  fullfilename = os.path.join('/tmp', 'imagesinfo')
  if os.path.exists(fullfilename):
   os.remove(fullfilename)
 
  for row in data :
    with open(fullfilename, 'a') as the_file:
      the_file.write(str(row[0])+"." + " " + str(row[1]) + "\n")
  
  mydb.close()
  with open (fullfilename, "r") as content_file:
     return content_file.read()
 except:
  output="Unable to list out the images info"
  return output
  exit()
 
def lambda_handler(event, context):
    error_output = "Unable to Save the Image" if event['action'] == "save" else "Unable to Fetch the data"
    try:
      if event['action'] == "save":
        final_output=saveimage(event)
        return final_output
      elif event['action'] == "list":
        final_output=listimage(event)
        return final_output
      else:
        error_output = "Please provide the action item"
        return error_output
        exit()
    except:
        return error_output
        exit()
