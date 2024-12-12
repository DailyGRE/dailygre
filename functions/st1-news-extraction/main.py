import base64
import json
import os
import requests
import utils
from datetime import datetime

from google.cloud import storage

BUCKET_NAME = os.environ.get("GCS_BUCKET_NAME")

def st1_news_extraction(event, context):
    start_time = utils.time.time()
    news_pages = {
    "washingtonpost": {
        "link": "http://feeds.washingtonpost.com/rss/world"
    },
    "scitechdaily": {
        "link": "https://scitechdaily.com/"
    },
    "nationalgeographic": {
        "link": "https://www.nationalgeographic.com/"
    },
    "artnews": {
        "link": "https://www.artnews.com/"
    },
    "medicalnewstoday": {
        "link": "https://www.medicalnewstoday.com/"
    }
    }

    news_saved = {}
    for news in news_pages:
        print("Analizing ", news)
        news_saved[news] = {}
        paper = utils.newspaper.build(news_pages[news].get("link"))
        if (len(paper.articles) > 0):
            print("Ok!")
            urls = []
            for count, article in enumerate(paper.articles):
                urls.append(article.url)
            news_saved[news] = urls
        else:
            print("No news from:", news)

    articles_read = utils.get_random_article(news_saved)

    print("Articles ready --- %s seconds ---" % (utils.time.time() - start_time))

    articles_to_epub = utils.get_article_structure(articles_read)

    # Convert results to a formatted string
    json_string = json.dumps(articles_to_epub, indent=4, ensure_ascii=False)

    # Define the GCS bucket name and destination file name
    current_date = datetime.now().strftime("%d%m%Y")

    destination_file_path = f"st1-raw/news_articles_{current_date}.json"

    # Initialize GCS client and bucket
    storage_client = storage.Client()
    bucket = storage_client.bucket(BUCKET_NAME)

    # Create a new blob and upload the JSON string as a JSON file
    blob = bucket.blob(destination_file_path)
    blob.upload_from_string(json_string, content_type="application/json")

    return f"File {destination_file_path} successfully uploaded to bucket {BUCKET_NAME}.", 200
