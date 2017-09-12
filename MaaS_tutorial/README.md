Let's augment the `squid` proxy sensor to use a model that will determine if the destination host is a domain generating algorithm.  For the purposes of demonstration, this algorithm is super simple and is implemented using Python with a REST interface exposed via the Flask python library.

## Preliminaries
It is expected that a few things are true:
* You should have squid data ingesting into kafka via NiFi or some other mechanism.
* On the metron access host, you should have the following environment variables set:
  * `METRON_HOME` - For HCP, this would be `/usr/hcp/current/metron/` and for Apache Metron, it woudl be `/usr/metron/$VERSION`
  * `ZK_QUORUM` - The zookeeper quorum (any one Zookeeper host)
  * `BROKERS` - The kafka brokers
  * `ES_MASTER` - The hostname for the ES master (if EC2, this would be the external hostname for this host)

## Install Prerequisites and Mock DGA Service

Now let's install some prerequisites, which have to be run on every data
node:
* Flask via `yum install python-flask`
* Jinja2 via `yum install python-jinja2`


You should also, if you have not already, install the ES Head plugin,
just to easily find data in ES after the fact
* ES Head plugin via `/usr/share/elasticsearch/bin/plugin install mobz/elasticsearch-head`


## Create the Mock DGA Service for Deployment

Now that we have flask and jinja, we can create a mock DGA service to deploy with MaaS:
* Download the files in [this](https://gist.github.com/cestella/cba10aff0f970078a4c2c8cade3a4d1a) gist into the `$HOME/mock_dga` directory
* Make `rest.sh` executable via `chmod +x $HOME/mock_dga/rest.sh`

This service will treat `yahoo.com` and `amazon.com` as legit and everything else as malicious.  The contract is that the REST service exposes an endpoint `/apply` and returns back JSON maps with a single key `is_malicious` which can be `malicious` or `legit`.

## Deploy Mock DGA Service via MaaS

The following presumes that you are a logged in as a user who has a
home directory in HDFS under `/user/$USER`.  If you do not, please create one
and ensure the permissions are set appropriate:
```
su - hdfs -c "hadoop fs -mkdir /user/$USER"
su - hdfs -c "hadoop fs -chown $USER:$USER /user/$USER"
```
Or, in the common case for the `metron` user:
```
su - hdfs -c "hadoop fs -mkdir /user/metron"
su - hdfs -c "hadoop fs -chown metron:metron /user/metron"
```

Now let's start MaaS and deploy the Mock DGA Service:
* Start MaaS via `$METRON_HOME/bin/maas_service.sh -zq $ZK_QUORUM`
* Start one instance of the mock DGA model with 512M of memory via `$METRON_HOME/bin/maas_deploy.sh -zq $ZK_QUORUM -lmp $HOME/mock_dga -hmp /user/metron/models -mo ADD -m 512 -n dga -v 1.0 -ni 1`
* As a sanity check:
  * Ensure that the model is running via `$METRON_HOME/bin/maas_deploy.sh -zq $ZK_QUORUM -mo LIST`.  You should see `Model dga @ 1.0` be displayed and under that a url such as (but not exactly) `http://node1:36161`
  * Try to hit the model via curl: `curl 'http://node1:36161/apply?host=caseystella.com'` and ensure that it returns a JSON map indicating the domain is malicious.

## Adjust Configurations for Squid to Call Model
Now that we have a deployed model, let's adjust the configurations for the Squid topology to annotate the messages with the output of the model.

* Edit the squid parser configuration at `$METRON_HOME/config/zookeeper/parsers/squid.json` in your favorite text editor and add a new FieldTransformation to indicate a threat alert based on the model (note the addition of `is_malicious` and `is_alert`):
```
{
  "parserClassName": "org.apache.metron.parsers.GrokParser",
  "sensorTopic": "squid",
  "parserConfig": {
    "grokPath": "/patterns/squid",
    "patternLabel": "SQUID_DELIMITED",
    "timestampField": "timestamp"
  },
  "fieldTransformations" : [
    {
      "transformation" : "STELLAR"
    ,"output" : [ "full_hostname", "domain_without_subdomains", "is_malicious", "is_alert" ]
    ,"config" : {
      "full_hostname" : "URL_TO_HOST(url)"
      ,"domain_without_subdomains" : "DOMAIN_REMOVE_SUBDOMAINS(full_hostname)"
      ,"is_malicious" : "MAP_GET('is_malicious', MAAS_MODEL_APPLY(MAAS_GET_ENDPOINT('dga'), {'host' : domain_without_subdomains}))"
      ,"is_alert" : "if is_malicious == 'malicious' then 'true' else null"
                }
    }
                           ]
}
```
* Edit the squid enrichment configuration at `$METRON_HOME/config/zookeeper/enrichments/squid.json` (this file will not exist, so create a new one) to make the threat triage adjust the level of risk based on the model output:
```
{
  "enrichment" : {
    "fieldMap": {}
  },
  "threatIntel" : {
    "fieldMap":{},
    "triageConfig" : {
      "riskLevelRules" : [
        {
          "rule" : "is_malicious == 'malicious'",
          "score" : 100
        }
      ],
      "aggregator" : "MAX"
    }
  }
}
```
* Upload new configs via `$METRON_HOME/bin/zk_load_configs.sh --mode PUSH -i $METRON_HOME/config/zookeeper -z $ZK_QUORUM`
* Make the Squid topic in kafka via `/usr/hdp/current/kafka-broker/bin/kafka-topics.sh --zookeeper $ZK_QUORUM --create --topic squid --partitions 1 --replication-factor 1`

## Start Topologies and Send Data
Now we need to start the topologies and send some data:
* Start the squid topology via `$METRON_HOME/bin/start_parser_topology.sh -k $BROKERS -z $ZK_QUORUM -s squid`
* Generate some data via the squid client by going to the following hosts:
  * http://yahoo.com
  * http://cnn.com
* Browse the data in elasticsearch via the ES Head plugin @ http://$ES_MASTER:9200/_plugin/head/ and verify that in the squid index you have two documents
  * One from `yahoo.com` which does not have `is_alert` set and does have `is_malicious` set to `legit`
  * One from `cnn.com` which does have `is_alert` set to `true`, `is_malicious` set to `malicious` and `threat:triage:level` set to 100
