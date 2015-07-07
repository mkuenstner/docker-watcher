Docker-Image to test elastic's [Watcher-Plugin](https://www.elastic.co/products/watcher).

Thanks to [Roy Russo](https://github.com/royrusso) for his [elasticsearch-sample-index-Project](https://github.com/royrusso/elasticsearch-sample-index).

# Building The Container
```bash
git clone git@github.com:mkuenstner/docker-watcher.git
cd docker/watcher
docker build -t=watcher .
```

# Launch The Container
```json
docker run -i -t -p 9200:9200  watcher
```

# Links
- Marvel: http://192.168.59.103:9200/_plugin/marvel
- Kopf: http://192.168.59.103:9200/_plugin/kopf


# Watcher
## Cluster Health
Checks the health of the cluster every 10s and alarm's if the status is red.
```json
PUT /_watcher/watch/cluster_health_watch
{
   "trigger": {
      "schedule": {
         "interval": "10s"
      }
   },
   "input": {
      "http": {
         "request": {
            "host": "localhost",
            "port": 9200,
            "path": "/_cluster/health"
         }
      }
   },
   "condition": {
      "compare": {
         "ctx.payload.status": {
            "eq": "red"
         }
      }
   },
   "actions": {
      "send_email": {
         "email": {
            "to": "root@localhost",
            "subject": "Cluster Status Warning",
            "body": "Cluster status is RED"
         }
      }
   }
}
```
## Amount of Documents in an Index
Checks the amount of documents in the comicbook-index and alarms, if less than 100 documents are present.
```json
PUT /_watcher/watch/comicbooks
{
   "trigger": {
      "schedule": {
         "interval": "10s"
      }
   },
   "input": {
      "http": {
         "request": {
            "host": "localhost",
            "port": 9200,
            "path": "/comicbook/_count"
         }
      }
   },
   "condition": {
      "compare": {
         "ctx.payload.count": {
            "lte": 100
         }
      }
   },
   "actions": {
      "send_email": {
         "email": {
            "to": "root@localhost",
            "subject": "Amount of Documents in Comicbooks",
            "body": "Less than 100 Docs in Index present"
         }
      }
   }
}
```

Delete some documents to test the Watcher:
```json
DELETE /comicbook/_query
{
    "query": {
        "wildcard": {
            "name": "*n"
        }
    }
}
```
Mails are being sent to `root@localhost` and can easly be viewed using `mutt`.


## Status
```json
GET /.watch_history*/_search
{
  "sort" : [
    { "result.execution_time" : "desc" }
  ]
}
```

## List all Watches
```json
GET .watches/_search
{
   "fields": [],
   "query": {
      "match_all": {}
   }
}
```

## Delete a Watch
```json
DELETE /_watcher/watch/comicbooks
```
