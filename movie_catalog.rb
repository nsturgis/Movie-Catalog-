require 'pg'
require 'pry'
require 'sinatra'
require 'sinatra/reloader'

def db_connection
  begin
    connection = PG.connect(dbname: 'movies')

    yield(connection)

  ensure
    connection.close
  end
end

get '/actors' do
    db_connection do |conn|
    @actors = conn.exec(query)
  end
  erb :'/actors/index'
end

get '/actors/:id' do
   id = params[:id]
   query = "SELECT actors.name, movies.title, cast_members.character FROM movies
   JOIN cast_members ON movies.id = cast_members.movie_id JOIN actors ON actors.id = cast_members.actor_id
   WHERE actors.id = #{id}"
   db_connection do |conn|
    @actor = conn.exec(query)

  end
  erb :'/actors/show'


end

get '/movies' do
query = "SELECT movies.title,movies.id, movies.year, movies.rating, genres.name AS genre, studios.name
AS studio FROM movies JOIN genres ON movies.genre_id = genres.id JOIN studios ON movies.studio_id = studios.id
"
if params[:order] == 'rating'
    query += 'ORDER BY movies.rating DESC'
  elsif params[:order] == 'year'
    query += 'ORDER BY movies.year DESC'
  else
    query += 'ORDER BY movies.title'
  end

  db_connection do |conn|
  @movies = conn.exec(query)
 end
  erb :'movies/index'

  end

get '/movies/:id' do
  id = params[:id]
  query = "SELECT movies.title, movies.year, movies.rating, movies.synopsis, genres.name AS genre, studios.name AS studio, actors.id,
  actors.name AS actors, cast_members.character AS character FROM movies JOIN cast_members ON movies.id = cast_members.movie_id
  JOIN actors ON actors.id = cast_members.actor_id JOIN genres ON movies.genre_id = genres.id
  JOIN studios ON movies.studio_id = studios.id WHERE movies.id = #{id}"
  db_connection do |conn|
    @movie = conn.exec(query)

  end
  erb :'/movies/show'

  end
