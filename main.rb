require 'json'
require 'jwt'
require 'sinatra/base'
require 'date'

class JwtAuth

  def initialize app
    @app = app
  end
  
  def call env
    begin
      #options = { algorithm: 'HS256', iss: ENV['JWT_ISSUER'] }
      options = { algorithm: 'HS256', iss: 'JWT_ISSUER' }
      bearer = env.fetch('HTTP_AUTHORIZATION', '').slice(7..-1)
      #payload, header = JWT.decode bearer, ENV['JWT_SECRET'], true, options 
      payload, header = JWT.decode bearer, 'JWT_SECRET', true, options 
      env[:user] = payload['user']
      @app.call env
      rescue JWT::ExpiredSignature
        [403, { 'Content-Type' => 'text/plain' }, ['El token expiró.']]
      rescue JWT::InvalidIssuerError
        [403, { 'Content-Type' => 'text/plain' }, ['El token no tienen un emisor válido.']]
      rescue JWT::InvalidIatError
        [403, { 'Content-Type' => 'text/plain' }, ['El token no tiene un tiempo de emisión válido.']]
      rescue JWT::DecodeError
        [401, { 'Content-Type' => 'text/plain' }, ['El token no es válido.']]
      end
    end
  
  end


class Api < Sinatra::Base

  use JwtAuth
  def initialize
    super
    @espacios = {
        "id_espacio": 2001,
        "nombre": "ALVAREZ HNOS.",
        "direccion": "Av. San Martín 164 1 27",
        "ciudad": "Rosario",
        "provincia": "Santa Fé",
        "pais": "Argentina",
        "correo": "alvarez@empresa.com",
        },
        
        {
        "id_espacio": 2002,
        "nombre": "MSA INDUSTRIAL SRL",
        "direccion": "Av. Facundo Manuel Quiroga 842",
        "ciudad": "Capilla del Monte",
        "provincia": "Cordoba",
        "pais": "Argentina",
        "correo": "msaindustrial@empresa.com",
        },
        
        {
        "id_espacio": 2003,
        "nombre": "SAMA SRL",
        "direccion": "Av. Jamaica 1245",
        "ciudad": "Brasilia",
        "provincia": "Brasilia",
        "pais": "Brasil",
        "correo": "sama@empresa.com",
        },
        
        {
        "id_espacio": 2004,
        "nombre": "DOMINO S.A.",
        "direccion": "Cl. 54 # 57-60, La Candelaria",
        "ciudad": "Santiago de Chile",
        "provincia": "Región Metropolitana",
        "pais": "Chile",
        "correo": "domino@empresa.com",
        },
        
        {
        "id_espacio": 2005,
        "nombre": "EMPRESAS CPP S.A.",
        "direccion": "Agustinas 1343",
        "ciudad": "Medellín",
        "provincia": "Antioquia",
        "pais": "Colombia",
        "correo": "cpp@empresa.com",
        }
    end
    
    post '/search' do
      dias = params[:dias].to_i
      arr = []
      costo = dias * 99 + 3000 + (rand 15000..20000)
      @espacios.sample(3).map{ |e|
        espacio = {}
        espacio["id_consulta"] = 6000 + (rand 999) 
        espacio["precio"] = (costo + rand(-250..250)).to_s + ' US$'
        espacio["espacio"] = e
        arr.push(espacio)    
      }
      arr.to_json
    end
      
    post '/reserve' do
      id = params[:id]
      if id.nil?
        return 'No se envió el id de la reserva'
      end
      id = id.to_i
      if id < 6000
        return 'No se puede realizar una reserva con ese id'
      end
      "Se realizó la reserva con identificador: #{id}"  
    end

    post '/cancel' do
      id = params[:id]
      if id.nil?
        return 'No se envió el id de la reserva a cancelar'
      end
      id = id.to_i
      if id < 6000
        return 'No existe una reserva para ese id'
      end
      "Se canceló la reserva con identificador: #{id}"  
    end

    not_found do
      'Uso incorrecto de la API, ingresa en: https://github.com/ucabrera/DSSD-reserva/tree/main/reserva-espacio para ver la documentación'
    end
  
  end
  
  class Public < Sinatra::Base
  
    def initialize
      super
    end

    post '/login' do
      username = params[:username]
      password = params[:password]
      if username.nil? || password.nil?
        'No se envió el usuario o la contraseña'  
      else  
        if username == 'wwglasses' && password == 'wwglasses'
          content_type :json
          { token: token(username) }.to_json
        else
          [401, { 'Content-Type' => 'text/plain' }, 'Usuario o contraseña no válidos.']
        end
      end
    end
  
    get '/' do
      redirect '/index.html'
    end
    
    not_found do
      'Uso incorrecto de la API, ingresa en: https://github.com/ucabrera/DSSD-reserva para ver la documentación'
    end
  
    private

    def token username
      JWT.encode payload(username), 'JWT_SECRET', 'HS256'
    end
    
    def payload username
      {
        exp: Time.now.to_i + 1600,
        iat: Time.now.to_i,
        #iss: ENV['JWT_ISSUER'],
        iss: 'JWT_ISSUER',
        user: {
          username: username
        }
      }
    end
  
  end