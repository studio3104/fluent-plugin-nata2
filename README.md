# fluent-plugin-nata2 [![Build Status](https://travis-ci.org/studio3104/fluent-plugin-nata2.png)](https://travis-ci.org/studio3104/fluent-plugin-nata2) [![Code Climate](https://codeclimate.com/github/studio3104/fluent-plugin-nata2.png)](https://codeclimate.com/github/studio3104/fluent-plugin-nata2)

fluent plugin to register slow query logs to [`Nata2`](https://github.com/studio3104/nata2)

## Installation

Add this line to your application's Gemfile:

    gem 'fluent-plugin-nata2'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fluent-plugin-nata2

## Plugins

`fluent-plugin-nata` bundles two plugins.

#### in_mysqlslowquery_ex

based `Fluent::NewTailInput`.  
tail and parse slow query log.

###### config parameters

- last_dbname_file
  - optional
  - specify the file to keep track of what was something of which database is slow query log which was produced at the end (slow query log of MySQL is not recorded each time it is either the slow query that occurred in any database)
  - must be specified a different path of `pos_file`

- dbname_if_missing_dbname_in_log
  - optional
  - value to be filled in case you did not know what was the slow query in any database

- format
  - alwayls `none`
  - impossible to specify virtually.

- read_from_head
  - optional
  - read from the beginning to slow query log

- path
  - required
  - path to slow query log

- tag
  - required
  - when used in combination with out_nata, it is necessary that the end is as shown in `servicename.hostname`.

#### out_nata2

post parsed slow query log to `Nata2 Server`.

###### config parameters

- server
  - required
  - server FQDN

- port
  - required
  - port of `Nata2 Server` bind

## Example configurations

```
<source>
  type mysqlslowquery_ex
  read_from_head
  path /path/to/slowquery.log
  tag slowquery.servicename.hostname
  pos_file /tmp/slowquery.log.pos
  last_dbname_file /tmp/slowquery.log.lastdb
</source>

<match slowquery.**>
  type nata2
  remove_tag_prefix slowquery.
  server nata2.server
  port 9292
</match>
```


## Contributing

1. Fork it ( http://github.com/studio3104/fluent-plugin-nata2/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
