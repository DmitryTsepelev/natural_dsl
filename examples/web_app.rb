require "bundler/inline"
require "socket"
require "json"

gemfile do
  source "https://rubygems.org"

  gem "natural_dsl"
  gem "pg"
end

# Before running:
#
# createdb my_app
# psql my_app
# create table users (id bigserial primary key, name varchar);
# insert into users (name) values ('John');
# insert into users (name) values ('Jane');
#
# In the first terminal window:
# ruby ./web_app.rb
#
# In the second terminal window:
#
# curl localhost:5678/users
# curl localhost:5678/users/1
# curl localhost:5678/users/42

class App
  def initialize(database)
    @connection = PG.connect(dbname: database)
  end

  def add_index_route(resource, expose)
    routes[resource.to_s] ||= {}
    routes[resource.to_s][:index] = {expose: expose}
  end

  def add_show_route(resource, key, expose)
    routes[resource.to_s] ||= {}
    routes[resource.to_s][:show] = {key: key, expose: expose}
  end

  def serve_from(port)
    server = TCPServer.new(port)

    loop do
      session = server.accept
      break unless session

      request = session.gets
      handle_request(request, session)
    end
  end

  private

  def handle_request(request, session)
    _, path = request.split(" ")

    _, table_name, key = path.split("/")
    route = routes[table_name]

    return render_not_found(session) if route.nil?

    if key.nil?
      handle_index_request(session, table_name, route.dig(:index, :expose))
    else
      return render_not_found(session) if route[:show].nil?
      handle_show_request(session, table_name, key, route[:show])
    end
  end

  def routes
    @routes ||= {}
  end

  def handle_index_request(session, table_name, fields)
    session.print "HTTP/1.1 200\r\n"
    session.print "Content-Type: text/html\r\n"
    session.print "\r\n"

    @connection.exec("SELECT * FROM #{table_name}") do |result|
      rows = result.map { |row| serialize(row, fields) }
      session.print rows.to_json
    end

    session.close
  end

  def handle_show_request(session, table_name, key, route_config)
    @connection.exec("SELECT * FROM #{table_name} WHERE #{route_config[:key]} = #{key}") do |result|
      row = result.first

      return render_not_found(session) unless row

      session.print "HTTP/1.1 200\r\n"
      session.print "Content-Type: text/html\r\n"
      session.print "\r\n"
      session.print(serialize(row, route_config[:expose]).to_json)
      session.close
    end
  end

  def serialize(data, fields)
    fields.map { |field| [field, data[field.to_s]] }.to_h
  end

  def render_not_found(session)
    session.print "HTTP/1.1 404\r\n"
    session.print "Content-Type: text/html\r\n"
    session.print "\r\n"
    session.print "Not found"

    session.close
  end
end

lang = NaturalDSL::Lang.define do
  command :connect do
    keyword :to
    keyword :database
    token

    execute do |vm, database|
      puts "Connecting to #{database.name}"

      app = App.new(database.name)
      vm.assign_variable(:app, app)
    end
  end

  command :list do
    token
    keyword :expose
    token.zero_or_more

    execute do |vm, resource, *expose|
      app = vm.read_variable(:app)
      app.add_index_route(resource.name, expose.map(&:name))
    end
  end

  command :show do
    token
    keyword :by
    token
    keyword :expose
    token.zero_or_more

    execute do |vm, resource, key, *expose|
      app = vm.read_variable(:app)
      app.add_show_route("#{resource.name}s", key.name, expose.map(&:name))
    end
  end

  command :serve do
    keyword(:from).with_value

    execute do |vm, port|
      puts "Starting server on #{port.value}"

      app = vm.read_variable(:app)
      app.serve_from(port.value)
    end
  end
end

NaturalDSL::VM.run(lang) do
  connect to database my_app

  list users expose id name
  show user by id expose id name

  serve from 5678
end
