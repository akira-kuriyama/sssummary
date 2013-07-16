# Sssummary

Summarize a formatted data like CSV by sql on the shell.

example:

```zsh:test.tsv
$ cat test.tsv
2013/07/01 23:08    0.100	iPhone
2013/07/01 23:08	0.160	iPhone
2013/07/01 23:09	0.120	Andoid
2013/07/01 23:09	0.103	Andoid
2013/07/01 23:09	0.140	IE10
2013/07/01 23:10	0.130	Chrome
2013/07/01 23:10	0.190	Firefox
2013/07/01 23:11	0.600	Safari
2013/07/01 23:11	0.890	Android
$ cat test.tsv | sssummary 'select c1, avg(c2) from t group by c1 order by c1'
2013/07/01 23:08    0.13
2013/07/01 23:09	0.121
2013/07/01 23:10	0.16
2013/07/01 23:11	0.745
```


## Installation

    $ yum install sqlite3 sqlite-devel

    $ gem install sssummary

## Usage

	usage: sssummary [OPTION]... SQL
	  -f, --file              file path for summarizing.
	                          If this option are not specified, read aggregation data from STANDARD INPUT.
	  -d, --database          database name.
	  -p, --database-file     the path where you want to save the database file.
	  -t, --table             table name.
	  -c, --columns           column names. (e.g., date,url,elapsed_time)
	  -s, --import-separator  The String placed between each field in import file. default string is TAB.
	  -o, --output-separator  The String placed between each field in output. default string is TAB.
	  -l, --leave-database    leave the database. If this option are not specified, delete the database file after processing.
	  -i, --ignore-header     ignore header(first line) in import file.
	  -v, --verbose           explain what is being done.
	  -h, --help              show this message.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

