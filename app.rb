require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'dm-is-reflective'
require "ruby_pagination_logic"

#Connect to Existing Heroku database
DataMapper.setup(:default, ENV['HEROKU_POSTGRESQL_OLIVE_URL'])

#Map existing table.
class Entry
   include DataMapper::Resource

   is :reflective #activate dm-is-reflective

   reflect #reflects eeach property.
end

# Finalize the DataMapper models.
DataMapper.finalize

get '/' do
  send_file './public/index.html'
end

# Route to show all Entries
get '/entries/all' do
  content_type :json
  @entries = Entry.all(:order => :pub_date.desc)

  @entries.to_json
end

#Simple paginated results
get '/entries/:page' do |page|
  @page = page.to_i
  limit = 5
  offset = RPL::paginate @page, limit
 
  @entries = Entry.all :limit => limit, :offset => offset, :order => 'pub_date'
 
  @entries.to_json
end

# READ: Route to show a specific Entry based on its `id`
get '/entries/:id' do
  content_type :json
  @entry = Entry.get(params[:id])

  if @entry
    @entry.to_json
  else
    halt 404
  end
end

