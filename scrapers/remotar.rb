class RemotarScraper
  def self.extrair_vagas(headers)
    # A URL de busca mudou; vamos usar a listagem geral que é mais segura
    url = "https://remotar.com.br/vagas"
    vagas_encontradas = []

    begin
      html = URI.open(url, **headers).read
      doc = Nokogiri::HTML(html, nil, 'UTF-8')

      # O seletor .card-job pode variar, vamos garantir que pegamos o link com segurança
      doc.css('.card-job').each do |card|
        link_tag = card.css('a').first
        next unless link_tag

        titulo = card.css('h2').text.strip
        # Só adicionamos se for relevante para sua stack (filtro simples antes da IA)
        if titulo.downcase.match?(/ruby|rails|java|spring|estágio|estagio/)
          vagas_encontradas << {
            titulo: titulo,
            link: "https://remotar.com.br#{link_tag['href']}",
            fonte: "Remotar"
          }
        end
      end
    rescue => e
      puts "⚠️ Erro ao acessar o Remotar: #{e.message}"
    end
    vagas_encontradas
  end
end
