require 'bundler/setup'
require 'nokogiri'
require 'open-uri'
require 'set'
require_relative 'analisador'
require_relative 'scrapers/remotar'
require_relative 'scrapers/programathor'

# Configurações Iniciais
ia = Analisador.new
headers = { "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" }
vagas_processadas = Set.new

puts "🚀 **Iniciando caçada multi-site: Programathor + Remotar**"

# 1. Coleta Consolidada
# O orquestrador solicita as listas sem se preocupar com a implementação interna
fila_de_vagas = []
fila_de_vagas += ProgramathorScraper.extrair_vagas(headers)
fila_de_vagas += RemotarScraper.extrair_vagas(headers)

puts "📊 **Total capturado:** #{fila_de_vagas.size} vagas. Iniciando análise técnica..."

# 2. Loop de Processamento Inteligente
fila_de_vagas.each do |vaga|
  # Extração de ID para evitar duplicatas na mesma execução
  id_vaga = vaga[:link].split('/').last
  next if vagas_processadas.include?(id_vaga)
  vagas_processadas.add(id_vaga)

  puts "\n" + "-" * 50
  puts "⏳ **Analisando [#{vaga[:fonte]}]:** #{vaga[:titulo]}"

  begin
    # Requisição ao detalhe da vaga
    html_detalhe = URI.open(vaga[:link], **headers).read
    doc_detalhe = Nokogiri::HTML(html_detalhe, nil, 'UTF-8')

    # Seleção de CSS baseada na fonte (Nil-safe)
    seletor = vaga[:fonte] == "Programathor" ? '.wrapper-content-job-show' : '.job-description'
    elemento_desc = doc_detalhe.css(seletor).first

    if elemento_desc
      # Limpeza de ruído no texto
      descricao = elemento_desc.text.strip.gsub(/\s+/, ' ')

      # Chamada para a IA (Gemini 2.5 Flash)
      analise = ia.avaliar_vaga(vaga[:titulo], descricao)

      # Filtro de Exibição (Score >= 60)
      if analise['score'] >= 60
        puts "✅ **MATCH ENCONTRADO (#{analise['score']}%)**"
        puts "🔗 **Link:** #{vaga[:link]}"
        puts "💡 **Veredito:** #{analise['justificativa']}"
      else
        puts "❌ **Ignorada:** Match de apenas #{analise['score']}%"
      end
    else
      puts "⚠️ **Erro:** Não foi possível localizar o corpo da descrição."
    end

    # Sleep estratégico para evitar bloqueios (Anti-Bot)
    sleep(2)

  rescue OpenURI::HTTPError => e
    puts "⚠️ **Erro de Conexão:** #{vaga[:fonte]} retornou #{e.message}"
  rescue StandardError => e
    puts "⚠️ **Erro Crítico:** #{e.message}"
  end
end

puts "\n🏁 **Varredura finalizada. Boa sorte na candidatura!**"
