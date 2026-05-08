require 'bundler/setup'
require 'nokogiri'
require 'open-uri'
require 'json' # Sai o Set, entra o JSON para memória permanente
require_relative 'analisador'
require_relative 'scrapers/remotar'
require_relative 'scrapers/programathor'
require_relative 'telegram_bot' # O Carteiro

# Configurações Iniciais
ia = Analisador.new
headers = { "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" }

# Memória de Longo Prazo
ARQUIVO_MEMORIA = 'vagas_vistas.json'
vagas_processadas = File.exist?(ARQUIVO_MEMORIA) ? JSON.parse(File.read(ARQUIVO_MEMORIA)) : []

puts "🚀 **Iniciando caçada diária: Programathor + Remotar**"

# 1. Coleta Consolidada
fila_de_vagas = []
fila_de_vagas += ProgramathorScraper.extrair_vagas(headers)
fila_de_vagas += RemotarScraper.extrair_vagas(headers)

puts "📊 **Total capturado:** #{fila_de_vagas.size} vagas. Filtrando o que já vimos..."

novos_matches = 0

# 2. Loop de Processamento Inteligente
fila_de_vagas.each do |vaga|
  id_vaga = vaga[:link].split('/').last

  # Ignora sumariamente se a vaga já estiver no JSON de execuções anteriores
  next if vagas_processadas.include?(id_vaga)

  # Filtro Rápido: Só gasta cota da API se o título fizer sentido
  palavras_chave = /junior|jr|estagio|estágio|pleno|rails|ruby|java|spring/i
  unless vaga[:titulo].match?(palavras_chave)
    puts "⏭️  **Pulando (Fora do alvo):** #{vaga[:titulo]}"
    vagas_processadas << id_vaga # Marca como vista para não avaliar amanhã
    next
  end

  puts "\n" + "-" * 50
  puts "⏳ **Analisando [#{vaga[:fonte]}]:** #{vaga[:titulo]}"

  begin
    html_detalhe = URI.open(vaga[:link], **headers).read
    doc_detalhe = Nokogiri::HTML(html_detalhe, nil, 'UTF-8')

    seletor = vaga[:fonte] == "Programathor" ? '.wrapper-content-job-show' : '.job-description'
    elemento_desc = doc_detalhe.css(seletor).first

    if elemento_desc
      descricao = elemento_desc.text.strip.gsub(/\s+/, ' ')
      analise = ia.avaliar_vaga(vaga[:titulo], descricao)

      if analise['score'] >= 60
        puts "✅ **MATCH ENCONTRADO (#{analise['score']}%)**"

        # Disparo para o Telegram
        mensagem = "🔥 *Nova Vaga Encontrada!*\n\n" \
                   "🏢 *Fonte:* #{vaga[:fonte]}\n" \
                   "🎯 *Score:* #{analise['score']}%\n" \
                   "💼 *Título:* [#{vaga[:titulo]}](#{vaga[:link]})\n" \
                   "💡 *Veredito:* #{analise['justificativa']}"

        TelegramBot.enviar(mensagem)
        novos_matches += 1
      else
        puts "❌ **Ignorada:** Match de apenas #{analise['score']}%"
      end
    else
      puts "⚠️ **Erro:** Não foi possível localizar o corpo da descrição."
    end

    # Grava na memória para não processar novamente
    vagas_processadas << id_vaga
    sleep(2)

  rescue OpenURI::HTTPError => e
    puts "⚠️ **Erro de Conexão:** #{vaga[:fonte]} retornou #{e.message}"
  rescue StandardError => e
    puts "⚠️ **Erro Crítico:** #{e.message}"
  end
end

# 3. Salva o estado atualizado no disco
File.write(ARQUIVO_MEMORIA, JSON.pretty_generate(vagas_processadas.uniq))
puts "\n🏁 **Varredura finalizada. #{novos_matches} alertas enviados para o seu Telegram.**"
