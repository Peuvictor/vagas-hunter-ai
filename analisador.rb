require 'net/http'
require 'uri'
require 'json'
require 'dotenv/load'

class Analisador
  def initialize
    @api_key = ENV['GEMINI_API_KEY']

    # Perfil atualizado com as novas skills e foco em transição
    @meu_perfil = {
      formacao: "Engenharia de Transportes (Raciocínio lógico forte)",
      stack_principal: "Ruby on Rails, Java/Spring Boot",
      infra: "PostgreSQL, Sidekiq, Docker, Google Cloud (GCP), Azure",
      extras: "JavaScript, Metodologias Ágeis (Scrum/Kanban)",
      projetos: "BH Agendamentos (SaaS), Filmow Scraper",
      senioridade_alvo: "Estágio, Junior ou Pleno"
    }.to_json
  end

  def avaliar_vaga(titulo_vaga, texto_vaga)
    # Usando o modelo que sua conta liberou
    url = URI("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=#{@api_key}")

    # Prompt ajustado para ser MAIS BRANDO e focar em potencial
    prompt = <<~PROMPT
      Você é um recrutador técnico parceiro do candidato.
      Seu objetivo é encontrar oportunidades onde um Desenvolvedor Junior com base sólida em Engenharia possa prosperar.

      Perfil do Candidato:
      #{@meu_perfil}

      Vaga: #{titulo_vaga}
      Descrição: #{texto_vaga}

      Avalie o match considerando:
      1. Se a vaga pede Junior/Pleno ou Estágio, o match deve ser ALTO.
      2. Se o candidato tem a stack principal (Ruby ou Java), valorize isso.
      3. Se a vaga pede Docker ou Nuvem (GCP/Azure), aumente a nota.
      4. Ignore exigências absurdas de tempo de experiência para vagas Junior.
      5. Se a vaga for Sênior ou Especialista, mantenha a nota baixa por segurança.

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

      if response.is_a?(Net::HTTPSuccess)
        dados = JSON.parse(response.body)
        texto_resposta = dados.dig("candidates", 0, "content", "parts", 0, "text")

        # Limpeza robusta do JSON
        json_limpo = texto_resposta.gsub(/```json\n?/, '').gsub(/
```/, '').strip
        JSON.parse(json_limpo)
      else
        puts ">>> ERRO DA API (Código #{response.code}): #{response.body}"
        { "score" => 0, "recomendado" => false, "justificativa" => "Falha na comunicação." }
      end
    rescue StandardError => e
      puts "Erro de execução: #{e.message}"
      { "score" => 0, "recomendado" => false, "justificativa" => "Erro interno." }
    end
  end
end
