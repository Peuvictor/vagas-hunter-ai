require 'nokogiri'
require 'open-uri'

puts "Buscando vagas de Rails..."

# 1. Definimos a URL alvo e disfarçamos nosso bot com um User-Agent para evitar bloqueios simples
url = 'https://programathor.com.br/jobs-ruby-on-rails'
headers = { "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" }

begin
  # 2. Abrimos a página e passamos para o Nokogiri interpretar o HTML
  html = URI.open(url, headers)
  doc = Nokogiri::HTML(html)

  # 3. Mapeamento do CSS (No Programathor, os cards de vagas geralmente usam a classe 'cell-list')
  vagas = doc.css('.cell-list')

  if vagas.empty?
    puts "Nenhuma vaga encontrada. O layout do site pode ter mudado e o seletor CSS precisa de ajuste."
  else
    # 4. Iteramos apenas sobre as 3 primeiras para validar a lógica
    vagas.first(3).each do |vaga|
      titulo = vaga.css('h3').text.strip
      link_parcial = vaga.css('a').first['href']

      puts "---"
      puts "Vaga: #{titulo}"
      puts "Link: https://programathor.com.br#{link_parcial}"
    end
  end

rescue StandardError => e
  puts "Erro ao acessar o site: #{e.message}"
end
