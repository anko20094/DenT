require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'DenT.db'
	@db.results_as_hash = true
end

def c_ctable
	@db.execute 'CREATE TABLE IF NOT EXISTS Posts (
		id INTEGER PRIMARY KEY AUTOINCREMENT, 
		created_date DATE, 
		content TEXT);'
end

before do
	init_db
end

configure do
	init_db
	c_ctable
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

	if content.length <=0
		@error = 'Type post text'
		return erb :new
	end
	#Збереження даних в БД
	@db.execute 'insert into Posts (content, created_date) values (?,datetime())', [content]
	redirect to '/'
end

get '/details/:post_id' do
	#Отримуємо змінну з URL-a
	post_id = params[:post_id]
	#Отримуємо список постів(в нас буде лише один пост)
	results = @db.execute 'select * from Posts where id = ?', [post_id]
	#Вибираємо цей один пост а змінну @row
	@row = results[0]
	#Вертаємо вигляд ERB
	erb :details
end