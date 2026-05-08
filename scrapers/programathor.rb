class ProgramathorScraper
  def self.extrair_vagas(headers)
    # Categorias verificadas; se uma der 404, o begin/rescue ignora e pula para a próxima
    categorias = ['ruby-on-rails', 'java', 'estagio']
    vagas_encontradas = []

    categorias.each do |cat|
      url = "https://programathor.com.br/jobs-#{cat}"
      begin
        html = URI.open(url, **headers).read
        doc = Nokogiri::HTML(html, nil, 'UTF-8')

        doc.css('.cell-list').each do |vaga|
          link_tag = vaga.css('a').first
          next unless link_tag # Pula se não encontrar o link (evita o erro '[]' for nil)

          vagas_encontradas << {
            titulo: vaga.css('h3').text.strip,
            link: "https://programathor.com.br#{link_tag['href']}",
            fonte: "Programathor"
          }
        end
      rescue OpenURI::HTTPError => e
        puts "⚠️ Categoria #{cat} não encontrada no Programathor (404)."
      rescue => e
        puts "⚠️ Erro inesperado no Programathor (#{cat}): #{e.message}"
      end
    end
    vagas_encontradas.uniq { |v| v[:link] }
  end
end
