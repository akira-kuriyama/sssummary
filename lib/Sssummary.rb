# -*- encoding: utf-8 -*-

require 'sqlite3'
require 'csv'

class Sssummary

	public
	def execute(options, sql)
		begin
			set_up(options, sql)

			@records = get_records
			create_table
			import
			result_records = execute_sql
			@messages << get_output(result_records)
			@exit_status = 0
		rescue FileEmptyError
			@exit_status = 1
			@messages << "Error : input data is empty!\n"
		ensure
			drop unless @db.nil?
		end
		return @exit_status, @messages.join("\n")
	end

	private
	def set_up(options, sql)
		@messages = []
		@messages << 'options : ' + options.to_s if options[:verbose]
		@options = options
		@sql = sql
		@input_file = get_input_file(options)
		@options[:import_separator] ||= "\t"
		@options[:output_separator] ||= "\t"
		@options[:db_name] ||= 'sssummary'
		@options[:table_name] ||= 't'
	end

	def get_input_file(options)
		input_file = nil
		if options[:file].nil?
			if File.pipe?(STDIN)
				input_file = STDIN
			end
		else
			input_file = open(options[:file])
		end
		input_file.gets if options[:ignore_header] && !input_file.nil?
		input_file
	end

	def get_records
		raise FileEmptyError if @input_file.nil?
		options = {:col_sep => @options[:import_separator], :skip_blanks => true}
		records = CSV.parse(@input_file, options)
		raise FileEmptyError if records.empty?
		records
	end

	def import
		insert_sql = 'INSERT INTO ' + @options[:table_name] +' VALUES('
		insert_sql += Array.new(@options[:column_names].length, '?').join(',')
		insert_sql +=');'
		@messages << 'insert sql : ' + insert_sql if @options[:verbose]
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

	def get_output(result_records)
		return if result_records.nil?
		@messages << 'sql : ' + @sql if @options[:verbose]
		options = {:col_sep => @options[:output_separator]}
		csv = CSV.generate('', options) do |csv|
			result_records.each do |record|
				csv << record
			end
		end
		@messages << 'result : ' if @options[:verbose]
		csv
	end

	def create_table
		@db = SQLite3::Database.new(get_dbfile_path)
		@messages << 'created Database at ' + get_dbfile_path if @options[:verbose]
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
		@messages << 'create table sql : ' + sql if @options[:verbose]
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
			@messages << 'drop Database at ' + get_dbfile_path if @options[:verbose]
		end
	end

	class FileEmptyError < StandardError;
	end
end
