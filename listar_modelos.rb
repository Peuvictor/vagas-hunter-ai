require 'net/http'
require 'uri'
require 'json'
require 'dotenv/load'

api_key = ENV['GEMINI_API_KEY']

if api_key.nil? || api_key.empty?
  puts "Erro: GEMINI_API_KEY não encontrada no .env"
  exit
end

url = URI("https://generativelanguage.googleapis.com/v1beta/models?key=#{api_key}")

begin
  response = Net::HTTP.get_response(url)

  if response.is_a?(Net::HTTPSuccess)
    dados = JSON.parse(response.body)
    puts "Modelos disponíveis para a sua chave que suportam generateContent:"
    puts "--------------------------------------------------------"

    dados['models'].each do |modelo|
      # Filtramos apenas os modelos que fazem o que precisamos
      if modelo['supportedGenerationMethods']&.include?('generateContent')
        puts "- #{modelo['name']}"
      end
    end
  else
    puts "Erro ao consultar a API: #{response.code}"
    puts response.body
  end
rescue StandardError => e
  puts "Erro de execução: #{e.message}"
end
