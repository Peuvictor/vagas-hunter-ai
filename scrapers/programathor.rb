require 'nokogiri'
require 'open-uri'

class ProgramathorScraper
  def self.extrair_vagas(headers)
    # Rota principal absoluta. Mais difícil de dar 404.
    url = "https://programathor.com.br/jobs"
    vagas_encontradas = []

    begin
      html = URI.open(url, **headers).read
      doc = Nokogiri::HTML(html, nil, 'UTF-8')

      doc.css('.cell-list').each do |vaga|
        link_tag = vaga.css('a').first
        next unless link_tag

        titulo_tag = vaga.css('h3').first
        next unless titulo_tag

        vagas_encontradas << {
          titulo: titulo_tag.text.strip,
          link: "https://programathor.com.br#{link_tag['href']}",
          fonte: "Programathor"
        }
      end
    rescue => e
      puts "⚠️ Erro no Programathor: #{e.message}"
    end

    vagas_encontradas.uniq { |v| v[:link] }
  end
end
