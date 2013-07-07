# -*- encoding: utf-8 -*-

module Sssummary
	require 'sqlite3'
	require 'CSV'

	class Sss

		public
		def execute(options, sql, input_file)
			begin
				set_up(options, sql, input_file)
				@records = get_records
				create_table
				import
				result_records = execute_sql
				output(result_records)
			ensure
				drop unless @db.nil?
			end
			exit(0)
		end

		private
		def set_up(options, sql, input_file)
			puts 'options : ' + options.to_s if options[:verbose]
			@options = options
			@sql = sql
			@input_file = input_file
			@options[:import_separator] ||= "\t"
			@options[:output_separator] ||= "\t"
			@options[:db_name] ||= 'db1'
			@options[:table_name] ||= 't'
		end

		# get data from STANDARD INPUT or FILE
		def get_records
			options = {:col_sep => @options[:import_separator], :skip_blanks => true}
			records = CSV.parse(@input_file, options)
			if records.empty?
				puts 'Error : input data is empty!'
				exit(1)
			end
			p records
			records
		end

		def import
			insert_sql = 'INSERT INTO t VALUES('
			insert_sql += Array.new(@options[:column_names].length, '?').join(',')
			insert_sql +=');'
			puts 'insert sql : ' + insert_sql if @options[:verbose]
			stmt = nil
			begin
				stmt = @db.prepare(insert_sql)
				@db.transaction do
					@records.each do |record|
						stmt.execute(record)
					end
				end
			ensure
				stmt.close unless stmt.nil?
			end
		end

		# output to STANDARD OUTPUT
		def output(result_records)
			return if result_records.nil?
			puts 'sql : ' + @sql if @options[:verbose]
			options = {:col_sep => @options[:output_separator]}
			csv = CSV.generate('', options) do |csv|
				result_records.each do |record|
					csv << record
				end
			end
			puts 'result : ' if @options[:verbose]
			print csv
		end

		def create_table
			@db = SQLite3::Database.new(get_dbfile_path)
			puts 'created Database at ' + get_dbfile_path if @options[:verbose]
			@db.execute(drop_table_sql)
			@db.execute(create_table_sql)
		end

		def get_dbfile_path
			dbfile_path = nil
			if @options[:dbfile].nil?
				dbfile_path = `pwd`.strip
			else
				dbfile_path = @options[:dbfile]
			end
			dbfile_path += '/' unless dbfile_path.end_with?('/')
			dbfile_path += @options[:db_name] + '.db'
		end

		def create_table_sql
			sql = "CREATE TABLE #{@options[:table_name]} ("
			sql += get_column_sql
			sql += ');'
			puts 'create table sql : ' + sql if @options[:verbose]
			sql
		end

		def get_column_sql
			column_names = @options[:column_names]
			if column_names.nil?
				column_names = []
				@records[0].length.times do |i|
					column_names << "c#{i+1}"
				end
				@options[:column_names] = column_names
			end
			column_sql = column_names.map do |column|
				s = column.split(':')
				if s.length == 1
					s << 'text'
				end
				s.join(' ')
			end
			column_sql.join(',')
		end

		def execute_sql
			return if @sql.nil?
			@db.execute(@sql)
		end

		#create index automatically by analyzing where clause.
		def create_index
			#TODO
		end

		def drop_table_sql
			"DROP TABLE IF EXISTS #{@options[:table_name]};"
		end

		def drop
			@db.close
			unless @options[:leave_database]
				File.delete(get_dbfile_path)
				puts 'drop Database at ' + get_dbfile_path if @options[:verbose]
			end
		end
	end

end
