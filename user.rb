require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'syntaxi'
require 'dm-core'

enable :sessions

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

DataMapper.setup(:default, "mysql://root:root@localhost/test")

class User

	include DataMapper::Resource
    property :name, String, :key => true  # any Type is available here
    property :pass, Text, :required => true

  end

class Texto

  include DataMapper::Resource

  property :id, Serial
  property :usuario, Text, :required => true
  #property :conteudo, Text, :required => true

  property :mensagem, Text
  property :imagem, Text
end

DataMapper.auto_upgrade!

get "/" do
	# na raiz carregar a página principal
	erb :index, :locals => { :session => session }
end

post "/" do

	user = User.all(:name => params[:name_conteudo], :pass => params[:pass_conteudo])
	if (user.count == 1)
		session[:name_conteudo] = params[:name_conteudo]
		erb :upload
	else
		redirect "/"
	end
end

get '/cadastro' do
  erb :cadastro
end

post '/cadastro' do
  user = User.new(:name => params[:name_conteudo], :pass => params[:pass_conteudo])
  if user.save
    redirect "/"
  else
    redirect "/cadastro"
  end
end

post '/clear' do
  session.clear
  redirect '/'
end



post '/upload' do
  unless params[:file] &&
   (tmpfile = params[:file][:tempfile]) &&
   (name = params[:file][:filename])
   @error = "No file selected"
   erb :upload 
  end

  if (params[:file] == nil)
  texto = Texto.new(:usuario=> session[:name_conteudo], 
                    :mensagem=> params[:mensage])
  texto.save   
  else
  path = File.join("public/uploads", name)
  File.open(path, "wb") { |f| f.write(tmpfile.read) }

  texto = Texto.new(:usuario=> session[:name_conteudo], :imagem=> params[:file][:filename],
                    :mensagem=> params[:mensage])
  texto.save 
  end

  @dados = Texto.all
  

 erb :upload 

end

