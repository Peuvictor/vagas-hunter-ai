require 'net/http'
require 'uri'
require 'json'
require 'dotenv/load'

class Analisador
  def initialize
    @api_key = ENV['GEMINI_API_KEY']

    @meu_perfil = {
      formacao: "Engenharia de Transportes (Raciocínio lógico forte)",
      stack_principal: "Ruby on Rails, Java/Spring Boot",
      infra: "PostgreSQL, Sidekiq, Docker, Google Cloud (GCP), Azure",
      extras: "JavaScript, Metodologias Ágeis (Scrum/Kanban)",
      projetos: "BH Agendamentos (SaaS), Filmow Scraper",
      senioridade_alvo: "Estágio ou Junior" # <-- Pleno removido daqui
    }.to_json
  end

  # Parâmetro de tentativas adicionado para evitar falha imediata
  def avaliar_vaga(titulo_vaga, texto_vaga, tentativas = 0)
    # Modelo cravado no 2.5-flash
    url = URI("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=#{@api_key}")

    prompt = <<~PROMPT
      Você é um recrutador técnico parceiro do candidato.
      Seu objetivo é encontrar oportunidades onde um Desenvolvedor Junior com base sólida em Engenharia possa prosperar.

      Perfil do Candidato:
      #{@meu_perfil}

      Vaga: #{titulo_vaga}
      Descrição: #{texto_vaga}

      Avalie o match considerando:
      1. A vaga DEVE ser explicitamente para Junior ou Estágio. Se a descrição pedir nível Pleno, Sênior ou Especialista, dê score 0.
      2. Se o candidato tem a stack principal (Ruby ou Java), valorize isso.
      3. Se a vaga pede Docker ou Nuvem (GCP/Azure), aumente a nota.
      4. Ignore exigências absurdas de tempo de experiência para vagas Junior.

      Retorne APENAS um JSON:
      {
        "score": (0 a 100),
        "recomendado": (true/false),
        "justificativa": (Máximo 2 frases, foque no potencial de aprendizado)
      }
    PROMPT

    payload = { contents: [{ parts: [{ text: prompt }] }] }
    headers = { 'Content-Type' => 'application/json' }

    begin
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(url.request_uri, headers)
      request.body = payload.to_json

      response = http.request(request)

      # Switch case para tratar as respostas do servidor com elegância
      case response.code.to_i
      when 200
        dados = JSON.parse(response.body)
        texto_resposta = dados.dig("candidates", 0, "content", "parts", 0, "text")

        # Regex corrigida e em linha única para não quebrar a sintaxe
        json_limpo = texto_resposta.gsub(/```json\n?/, '').gsub(/
```/, '').strip
        return JSON.parse(json_limpo)

      when 429
        # Respeita o limite da API (Free Tier) pausando a execução
        if tentativas < 2
          puts "🚨 Cota atingida (429). Pausando a execução por 45 segundos..."
          sleep(45)
          return avaliar_vaga(titulo_vaga, texto_vaga, tentativas + 1)
        else
          return { "score" => 0, "recomendado" => false, "justificativa" => "Cota da API esgotada." }
        end

      when 503
        # Trata instabilidade temporária do servidor do Google
        if tentativas < 3
          puts "⚠️ Servidor ocupado (503). Retentando em 5 segundos..."
          sleep(5)
          return avaliar_vaga(titulo_vaga, texto_vaga, tentativas + 1)
        else
          return { "score" => 0, "recomendado" => false, "justificativa" => "Servidor do Google indisponível." }
        end

      else
        puts ">>> ERRO DA API (Código #{response.code}): #{response.body}"
        return { "score" => 0, "recomendado" => false, "justificativa" => "Erro HTTP não mapeado." }
      end

    rescue StandardError => e
      puts "Erro de execução interna: #{e.message}"
      return { "score" => 0, "recomendado" => false, "justificativa" => "Erro interno no script Ruby." }
    end
  end
end
