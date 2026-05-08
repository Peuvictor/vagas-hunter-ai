require 'bundler/setup'
require 'nokogiri'
require 'open-uri'
require 'set'
require_relative 'analisador'

puts "🚀 Iniciando caçada: Rails, Java, Spring Boot e Estágios..."

ia = Analisador.new
headers = { "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" }

# Lista de alvos refinada
urls = [
  'https://programathor.com.br/jobs-ruby-on-rails',
  'https://programathor.com.br/jobs-java',
  'https://programathor.com.br/jobs-spring-boot',
  'https://programathor.com.br/jobs-estagio'
]

urls.each do |url|
  begin
    puts "\n🔎 Vasculhando: #{url.split('-').last.upcase}..."
    html = URI.open(url, **headers).read
    doc = Nokogiri::HTML(html, nil, 'UTF-8')
    vagas = doc.css('.cell-list')

    if vagas.empty?
      puts "⚠️ Nenhuma vaga recente nesta categoria."
      next
    end

    # Analisando as 2 primeiras de cada categoria para teste
    vagas.first(2).each do |vaga|
      titulo = vaga.css('h3').text.strip
      link_parcial = vaga.css('a').first['href']
      url_da_vaga = "https://programathor.com.br#{link_parcial}"

      print "⏳ Analisando: #{titulo[0..30]}... "

      html_detalhe = URI.open(url_da_vaga, **headers).read
      doc_detalhe = Nokogiri::HTML(html_detalhe, nil, 'UTF-8')
      descricao = doc_detalhe.css('.wrapper-content-job-show').text.strip.gsub(/\s+/, ' ')

      analise = ia.avaliar_vaga(titulo, descricao)

      # Filtro de relevância: Score acima de 60%
      if analise['score'] >= 60
        puts "\n✅ MATCH (Score: #{analise['score']}%)"
        puts "🔗 Link: #{url_da_vaga}"
        puts "💡 Por que: #{analise['justificativa']}"
        puts "---"
      else
        puts "❌ Irrelevante (#{analise['score']}%)"
      end
    end

  rescue StandardError => e
    puts "\n❌ Erro ao acessar #{url}: #{e.message}"
  end
end

puts "\n🏁 Varredura finalizada. Se houver match, o link está acima."

vagas_processadas = Set.new # Memória da sessão atual

urls.each do |url|
  begin
    puts "\n🔎 Vasculhando: #{url.split('-').last.upcase}..."
    html = URI.open(url, **headers).read
    doc = Nokogiri::HTML(html, nil, 'UTF-8')
    vagas = doc.css('.cell-list')

    vagas.first(3).each do |vaga|
      link_parcial = vaga.css('a').first['href']
      id_vaga = link_parcial.split('/').last # Extrai o ID único da vaga

      # Pulo do gato: Se já processamos esse ID, pula para a próxima
      if vagas_processadas.include?(id_vaga)
        next
      end

      vagas_processadas.add(id_vaga)

      titulo = vaga.css('h3').text.strip
      url_da_vaga = "https://programathor.com.br#{link_parcial}"

      # Pequeno sleep para evitar o erro 500/bloqueio de bot
      sleep(1.5)

      print "⏳ Analisando: #{titulo[0..30]}... "
      # ... (resto do código de análise)
    end
  rescue StandardError => e
    puts "\n❌ Erro ao acessar #{url}: #{e.message}"
  end
end
