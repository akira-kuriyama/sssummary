#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-


require 'rubygems'
require_relative '../lib/sss'
require 'optparse'

options = {}
opt = OptionParser.new
opt.on('-f FILE', '--file=FILE') { |v| options[:file] = v }
opt.on('-p DBFILE', '--database-file=DBFILE') { |v| options[:dbfile] = v }
opt.on('-d DB', '--database=DB') { |v| options[:db_name] = v }
opt.on('-t TABLE', '--table=TABLE') { |v| options[:table_name] = v }
opt.on('-c COLUMNS', '--columns=COLUMNS') { |v| options[:column_names] = v.split(',') }
opt.on('-s IMPORT-SEPARATOR', '--import-separator=IMPORT-SEPARATOR') { |v| options[:import_separator] = v }
opt.on('-o OUTPUT-SEPARATOR', '--output-separator=OUTPUT-SEPARATOR') { |v| options[:output_separator] = v }
opt.on('-u', '--leave-database') { |v| options[:leave_database] = v }
opt.on('-i', '--ignore-header') { |v| options[:ignore_header] = v }
opt.on('-v', '--verbose') { |v| options[:verbose] = v }
opt.on('-h', '--help') { |v| options[:help] = v }
begin
	opt.permute!(ARGV)
rescue OptionParser::ParseError
	options[:error] = true
end
show_help if options[:error] || options[:help]
sql = ARGV[0]

def show_help
	puts <<"EOH"
usage: scollct [OPTION]... SQL
  -f, --file              file path for aggregation.
                          If this option are not specified, read aggregation data from STANDARD INPUT.
  -d, --database          database name.
  -p, --database file     the path where you want to save the database file.
  -t, --table             table name.
  -c, --columns           column names. (e.g., date,url,elapsed_time)
  -s, --import-separator  The String placed between each field in import file. default string is TAB.
  -o, --output-separator  The String placed between each field in output. default string is TAB.
  -l, --leave-database    leave the database. If this option are not specified, delete the database file after processing.
  -i, --ignore-header     ignore header(first line) in import file
  -v, --verbose           explain what is being done.
  -h, --help              show this message
EOH
	exit(0) if options[:help]
	exit(1)
end

def get_input_file(options)
	STDIN.gets if options[:ignore_header]
	input_file = nil
	if options[:file].nil?
		if File.pipe?(STDIN)
			input_file = STDIN
		else
			puts 'Error : input data is empty!'
			exit(1)
		end
	else
		input_file = File.read(options[:file])
	end
	input_file
end

retval = Sssummary::Sss.new.execute(options, sql, get_input_file(options))
exit retval