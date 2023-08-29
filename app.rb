require 'bundler'
Bundler.require

require 'sinatra'

Faye::WebSocket.load_adapter('thin')

set :port, ENV['PORT'] || 3100
set :bind, '0.0.0.0'

# location of the quantized model bin file generated by llama.cpp
MODEL = ENV["MODEL_PATH"] || "/data/models/model.bin"

params = LLaMACpp::ContextParams.new
params.seed = 42
model = LLaMACpp::Model.new(model_path: MODEL, params: params)
context = LLaMACpp::Context.new(model: model)

def build_prompt(instruction, input)
  "Below is an instruction that describes a task, paired with an input that provides further context. Write a response that appropriately completes the request.\n" +
  "### Instruction:\n" + instruction + "\n### Input:\n" + input + "\n### Response:\n"
end

set :sockets, []
set :n_threads, (ENV['N_THREADS'] || 8).to_i

get '/' do
  @server_name = ENV['SERVER_NAME'] || 'localhost'
  erb :chat, { :locals => { :host_name => @server_name, :port => settings.port } }
end

get '/chat' do
  @server_name = ENV['SERVER_NAME'] || 'localhost'
  if Faye::WebSocket.websocket?(request.env)
    ws = Faye::WebSocket.new(request.env)

    ws.on :open do |event|
      logger.info("open #{ws}")
      settings.sockets << ws
      ws.send({type: 'info', message: ''}.to_json)
    end

    ws.on :message do |event|
      data = JSON.parse(event.data)
      case data['type']
      when 'ping'
        ws.send({type: 'ping', message: 'pong'}.to_json)
      when 'generate'
        query = data['message']
        n_predict = (data['n_predict'] || 128).to_i
        logger.info(query)
        Thread.new do
          output = LLaMACpp.generate(context, query, n_threads: settings.n_threads, n_predict: n_predict)
          logger.info("response: [#{output}]...")
          ws.send({type: 'message', user: data['user'], message: output}.to_json)
        end
      when 'message'
        query = build_prompt(data['context'], data['message'])
        n_predict = (data['n_predict'] || 128).to_i
        logger.info(query)

        # Move long-running task to a separate thread
        Thread.new do
          output = LLaMACpp.generate(context, query, n_threads: settings.n_threads, n_predict: n_predict)
          logger.info("response: [#{output}]...")
          matches = output.scan(/### Response:\n(.*?)(?=###|\z)/m)
          message =  matches[0]
          logger.info("response: [#{message[0]}]...")
          ws.send({type: 'message', user: data['user'], message: message[0]}.to_json)
        end
      else
        ws.send({type: 'error', message: 'Unknown command!'}.to_json)
      end
    end

    ws.on :close do |event|
      logger.info("close #{ws}")
      settings.sockets.delete(ws)
    end

    ws.rack_response
  else
    
    erb :chat, { :locals => { :host_name => @server_name, :port => settings.port } }
  end
end