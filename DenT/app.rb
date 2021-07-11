require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'DenT.db'
	@db.results_as_hash = true
end

def creat_posts_table
	@db.execute 'CREATE TABLE IF NOT EXISTS Posts (
		id INTEGER PRIMARY KEY AUTOINCREMENT, 
		created_date DATE, 
		content TEXT,
		author TEXT);'
end

def creat_comments_table
	@db.execute 'CREATE TABLE IF NOT EXISTS Comments (
		id INTEGER PRIMARY KEY AUTOINCREMENT, 
		created_date DATE, 
		comment TEXT,
		post_id integer);'
end

before do
	init_db
end

configure do
	init_db
	creat_posts_table
	creat_comments_table
end

get '/' do
	@results = @db.execute 'select * from Posts order by id desc'

	erb :index
end

get '/new' do
	erb :new
end

post '/new' do
	content = params[:content]
	author = params[:author]

	if content.length <=0
		@error = 'Type post text'
		return erb :new
	end
	#Збереження даних в БД
	@db.execute 'insert into Posts (content, created_date, author) values (?,datetime(), ?)', [content, author]
	redirect to '/'
end

get '/details/:post_id' do
	#Отримуємо змінну з URL-a
	post_id = params[:post_id]
	#Отримуємо список постів(в нас буде лише один пост)
	results = @db.execute 'select * from Posts where id = ?', [post_id]
	#Вибираємо цей один пост а змінну @row
	@row = results[0]
	#Вибираємо коментарі для нашого поста
	@comments = @db.execute 'select * from Comments where post_id = ? order by id', [post_id]
	#Вертаємо вигляд ERB
	erb :details
end


post '/details/:post_id' do
	post_id = params[:post_id]

	comment = params[:comment]

	@db.execute 'insert into Comments
	(
		comment,
		created_date,
		post_id
	) 
	values (?,datetime(), ?)', [comment, post_id]

	erb "You typed comment: #{comment}, for post #{post_id}"
	redirect to ('/details/' + post_id)
end