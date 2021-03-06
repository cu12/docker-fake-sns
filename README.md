[![](https://badge.imagelayers.io/seayou/fake-sns:latest.svg)](https://imagelayers.io/?images=seayou/fake-sns:latest 'Get your own badge on imagelayers.io')

### Fake-SNS
Docker image for the fake_sns gem. Currently uses a forked copy of the gem, as development has stagnated, and a bug, which is critical for dockerization, is still outstanding. See: [pull request](https://github.com/yourkarma/fake_sns/pull/5)

* This is a fork of [feathj/fake-sns](https://hub.docker.com/r/feathj/fake-sns/) and includes awscli in the container to easily manipulate SNS topics from CLI.
  The image is using Alpine linux (gliderlabs/alpine), making its size around 34 MB instead of the original 278 MB.

* Also a notable difference, that it uses [Tini](https://github.com/krallin/tini), a minimalistic init system to handle signaling properly.

##### Features
Works off of forked copy of original gem to allow proper dockerization
Uses thin as webserver to prevent reverse dns lookup (causing big slowdowns)
Exposes fake_sns database to "/messages/sns" VOLUME for file based verification

##### Running
`$ docker run -it -p 9292:9292 seayou/fake-sns`

Note that VIRTUAL_HOST environment variable can be added if run with dinghy client
`$ docker run -it -p 9292:9292 -e VIRTUAL_HOST=sns.docker seayou/fake-sns`

Or from docker-compose.yml:

```yaml
sns:
  image: seayou/fake-sns
  ports:
    - "9292:9292"
  environment:
    VIRTUAL_HOST: "sns.docker"
```

##### Getting started

Creating topics are easy with awscli, just run:

```sh
$ docker exec <CONTAINER_ID> bash -c "AWS_ACCESS_KEY_ID=fake AWS_SECRET_ACCESS_KEY=fake AWS_DEFAULT_REGION=fake aws --endpoint-url http://localhost:9292 sns create-topic --output text --name <TOPIC_NAME>"
```

The following ruby code can be used to verify that the container is running properly

```ruby
require 'aws-sdk'
require 'aws-sdk-core'
require 'aws-sdk-resources'
require 'aws-sdk-v1'

AWS.config(
  use_ssl: false,
  sns_endpoint: 'sns.docker',
  sns_port: 9292
)

sns = AWS::SNS::Client.new(
  access_key_id: '',
  secret_access_key: ''
)

t = sns.create_topic(name: 'testTopic')
resp = sns.publish(topic_arn: t.topic_arn, message: '{test: true}', message_structure: 'json')
puts resp
```
