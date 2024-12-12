import random
from newspaper import Article


def get_article(article_url):
    url = article_url
    article = Article(url)
    article.download()
    article.html
    article.parse()
    article_data = {}
    article_data['author'] = article.authors if (len(article.authors) != 0) else "N/A"
    try:
        article_data['publish_date'] = article.publish_date.strftime('%m/%d/%Y')
    except:
        article_data['publish_date'] = "N/A"
    article_data['text'] = article.text.replace("'","\'").replace('"','\"')
    return article_data

def get_article_structure(articles_to_read):
    structure = {}
    for article in articles_to_read:
        #print(article,articles_to_read[article])
        structure[article] = get_article(articles_to_read[article])
    return structure

def get_random_article(list_articles):
    articles_read = {}
    for news in list_articles:
        count_articles = len(list_articles[news])
        if count_articles > 0:
            random_article = random.randrange(count_articles)-1
            articles_read[news] = list_articles[news][random_article]
    return articles_read