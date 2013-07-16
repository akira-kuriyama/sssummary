# -*- coding: utf-8 -*-
require 'rspec'
require_relative '../lib/Sssummary'

describe 'Sssummary' do

	it 'SQLが実行されること' do
		options = {}
		options[:file] = 'spec/test_file/test.tsv'
		sql= 'select * from t order by c1'
		exit_status, output = Sssummary.new.execute(options, sql)

		exit_status.should == 0
		output.should == File.read('spec/test_file/test_result.tsv').to_s
	end

	it 'インポートされるファイルが空だった場合、エラーメッセージが出力されること' do
		options = {}
		sql= 'select * from t order by c1'
		options[:file] = 'spec/test_file/test_empty.tsv'
		exit_status, output = Sssummary.new.execute(options, sql)

		exit_status.should == 1
		output.should == File.read('spec/test_file/test_empty_result.tsv').to_s
	end

	it 'インポートされるファイル場所が存在しなかった場合、エラーが発生すること' do
		options = {}
		sql= 'select * from t order by c1'
		options[:file] = 'spec/test_file/not_exists.tsv'

		lambda {
			exit_status, output = Sssummary.new.execute(options, sql)
		}.should raise_error(Errno::ENOENT)
	end

	it 'dbfileの保存場所を指定しない場合、カレントディレクトリに保存されること' do
		options = {}
		options[:file] = 'spec/test_file/test.tsv'
		options[:leave_database] = true
		sql= 'select * from t order by c1'
		exit_status, output = Sssummary.new.execute(options, sql)

		exit_status.should == 0
		output.should == File.read('spec/test_file/test_result.tsv').to_s
		File.exist?('sssummary.db').should be_true
		File.delete('sssummary.db')
	end

	it 'dbfileの保存場所を指定した場合、その保存場所にdbfileが作成されること' do
		options = {}
		options[:file] = 'spec/test_file/test.tsv'
		options[:leave_database] = true
		options[:dbfile] = 'spec/test_file'
		sql= 'select * from t order by c1'
		exit_status, output = Sssummary.new.execute(options, sql)

		exit_status.should == 0
		output.should == File.read('spec/test_file/test_result.tsv').to_s
		File.exist?('spec/test_file/sssummary.db').should be_true
		File.delete('spec/test_file/sssummary.db')
	end

	it 'dbfileの保存場所が不正だった場合、エラーが発生すること' do
		options = {}
		options[:file] = 'spec/test_file/test.tsv'
		options[:dbfile] = 'spec/not_exists'
		sql= 'select * from t order by c1'
		lambda {
			exit_status, output = Sssummary.new.execute(options, sql)
		}.should raise_error(SQLite3::CantOpenException)
	end

	it 'db名を指定しない場合、デフォルトのdb名になること' do
		options = {}
		options[:file] = 'spec/test_file/test.tsv'
		options[:leave_database] = true
		sql= 'select * from t order by c1'
		exit_status, output = Sssummary.new.execute(options, sql)

		exit_status.should == 0
		output.should == File.read('spec/test_file/test_result.tsv').to_s
		File.exist?('sssummary.db').should be_true
		File.delete('sssummary.db')
	end

	it 'db名を指定した場合、指定されたdb名になること' do
		options = {}
		options[:file] = 'spec/test_file/test.tsv'
		options[:leave_database] = true
		options[:db_name] = 'special'

		sql= 'select * from t order by c1'
		exit_status, output = Sssummary.new.execute(options, sql)

		exit_status.should == 0
		output.should == File.read('spec/test_file/test_result.tsv').to_s
		File.exist?('special.db').should be_true
		File.delete('special.db')
	end

	it 'テーブル名を指定しない場合、デフォルトのテーブル名になること' do
		options = {}
		options[:file] = 'spec/test_file/test.tsv'
		sql= 'select * from t order by c1'
		exit_status, output = Sssummary.new.execute(options, sql)

		exit_status.should == 0
		output.should == File.read('spec/test_file/test_result.tsv').to_s
	end

	it 'テーブル名を指定した場合、指定されたテーブル名になること' do
		options = {}
		options[:file] = 'spec/test_file/test.tsv'
		options[:table_name] = 'log'
		sql= 'select * from log order by c1'
		exit_status, output = Sssummary.new.execute(options, sql)

		exit_status.should == 0
		output.should == File.read('spec/test_file/test_result.tsv').to_s
	end

	it '不正なテーブル名を指定した場合、エラーになること' do
		options = {}
		options[:file] = 'spec/test_file/test.tsv'
		options[:table_name] = 'select'
		sql= 'select * from select order by c1'

		lambda {
			exit_status, output = Sssummary.new.execute(options, sql)
		}.should raise_error(SQLite3::SQLException)
	end

	it 'カラム名を指定しない場合、デフォルトのカラム名になること' do
		options = {}
		options[:file] = 'spec/test_file/test.tsv'
		sql= 'select c1, c2, c3 from t order by c1'
		exit_status, output = Sssummary.new.execute(options, sql)

		exit_status.should == 0
		output.should == File.read('spec/test_file/test_result.tsv').to_s
	end

	it 'カラム名を指定した場合、指定されたカラム名になること' do
		options = {}
		options[:file] = 'spec/test_file/test_column_names.tsv'
		options[:column_names] = 'time,elapsed,ua'.split(',')
		sql= 'select time, elapsed, ua from t order by time'
		exit_status, output = Sssummary.new.execute(options, sql)

		exit_status.should == 0
		output.should == File.read('spec/test_file/test_column_names_result.tsv').to_s
	end

	it '不正なカラム名を指定した場合、エラーが発生すること' do
		options = {}
		options[:file] = 'spec/test_file/test_column_names.tsv'
		options[:column_names] = 'select,elapsed,ua'.split(',')
		sql= 'select time, elapsed, ua from t order by time'

		lambda {
			exit_status, output = Sssummary.new.execute(options, sql)
		}.should raise_error(SQLite3::SQLException)
	end

	it 'インポートするファイルの区切り文字を指定しない場合、タブ区切りでparseされること' do
		options = {}
		options[:file] = 'spec/test_file/test.tsv'
		sql= 'select * from t order by c1'
		exit_status, output = Sssummary.new.execute(options, sql)

		exit_status.should == 0
		output.should == File.read('spec/test_file/test_result.tsv').to_s
	end

	it 'インポートするファイルの区切り文字を指定した場合、その区切り文字でparseされること' do
		options = {}
		options[:file] = 'spec/test_file/test.csv'
		options[:import_separator] = ','
		sql= 'select * from t order by c1'
		exit_status, output = Sssummary.new.execute(options, sql)

		exit_status.should == 0
		output.should == File.read('spec/test_file/test_result.csv').to_s
	end

	it 'アウトプットの区切り文字を指定しない場合、タグ区切り文字で出力されること' do
		options = {}
		options[:file] = 'spec/test_file/test.tsv'
		sql= 'select * from t order by c1'
		exit_status, output = Sssummary.new.execute(options, sql)

		exit_status.should == 0
		output.should == File.read('spec/test_file/test_result.tsv').to_s
	end

	it 'アウトプットの区切り文字を指定した場合、その区切り文字で出力されること' do
		options = {}
		options[:file] = 'spec/test_file/test.tsv'
		options[:output_separator] = ','
		sql= 'select * from t order by c1'
		exit_status, output = Sssummary.new.execute(options, sql)

		exit_status.should == 0
		output.should == File.read('spec/test_file/test_output_separator_result.csv').to_s
	end

	it 'leave-databaseオプションを指定しない場合、実行後にdbファイルが削除されていること' do
		options = {}
		options[:file] = 'spec/test_file/test.tsv'
		sql= 'select * from t order by c1'
		exit_status, output = Sssummary.new.execute(options, sql)

		exit_status.should == 0
		output.should == File.read('spec/test_file/test_result.tsv').to_s
		File.exist?('sssummary.db').should be_false
	end

	it 'leave-databaseオプションを指定した場合、実行後にdbファイルが削除されていないこと' do
		options = {}
		options[:file] = 'spec/test_file/test.tsv'
		options[:leave_database] = true
		sql= 'select * from t order by c1'
		exit_status, output = Sssummary.new.execute(options, sql)

		exit_status.should == 0
		output.should == File.read('spec/test_file/test_result.tsv').to_s
		File.exist?('sssummary.db').should be_true
		File.delete('sssummary.db')
	end

	it 'ignore-headerオプションを指定しない場合、ヘッダーはインポートされること' do
		options = {}
		sql= 'select * from t order by c1'
		options[:file] = 'spec/test_file/test_header.tsv'
		exit_status, output = Sssummary.new.execute(options, sql)

		exit_status.should == 0
		output.should == File.read('spec/test_file/test_header_result1.tsv').to_s
	end

	it 'ignore-headerオプションを指定した場合、ヘッダーはインポートされないこと' do
		options = {}
		options[:ignore_header] = true
		options[:file] = 'spec/test_file/test_header.tsv'
		sql= 'select * from t order by c1'

		exit_status, output = Sssummary.new.execute(options, sql)

		exit_status.should == 0
		output.should == File.read('spec/test_file/test_header_result2.tsv').to_s
	end

	it 'verboseオプションを指定しない場合、詳細メッセージは表示されないこと' do
		options = {}
		options[:file] = 'spec/test_file/test.tsv'
		sql= 'select * from t order by c1'
		exit_status, output = Sssummary.new.execute(options, sql)

		exit_status.should == 0
		output.should == File.read('spec/test_file/test_result.tsv').to_s
	end

	it 'verboseオプションを指定した場合、詳細メッセージは表示されること' do
		options = {}
		options[:file] = 'spec/test_file/test.tsv'
		options[:verbose] = true
		sql= 'select * from t order by c1'
		exit_status, output = Sssummary.new.execute(options, sql)

		exit_status.should == 0
		result = File.read('spec/test_file/test_verbose_result.tsv').to_s.gsub('#pwd#', `pwd`.strip)
		output.should == result
	end

	it '複雑なSQLが実行できること' do
		options = {}
		options[:file] = 'spec/test_file/test.tsv'
		options[:column_names] = 'time,elapsed,ua'.split(',')
		sql= 'select time, avg(elapsed) from t where ua like \'%Android%\' group by time order by avg(elapsed)'
		exit_status, output = Sssummary.new.execute(options, sql)

		exit_status.should == 0
		output.should == File.read('spec/test_file/test_complex_sql_result.tsv').to_s
	end

	it '不正なSQLを実行した場合、エラーが発生すること' do
		options = {}
		options[:file] = 'spec/test_file/test_ngtest.tsv'
		options[:import_separator] = ','
		options[:column_names] = 'time,elapsed,ua'.split(',')
		sql= 'select time, avg(elapsed) from t where ua like \'%Android%\' group by time order by avg(elapsed)'
		lambda {
			exit_status, output = Sssummary.new.execute(options, sql)
		}.should raise_error(SQLite3::RangeException)
	end

end