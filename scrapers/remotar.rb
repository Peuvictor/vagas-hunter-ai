require 'nokogiri'
require 'open-uri'

class RemotarScraper
  def self.extrair_vagas(headers)
    # Ataca a raiz do site
    url = "https://remotar.com.br/"
    vagas_encontradas = []

    begin
      html = URI.open(url, **headers).read
      doc = Nokogiri::HTML(html, nil, 'UTF-8')

      # Busca genérica por links de vagas, imune a mudanças de CSS
      doc.css('a').each do |link_tag|
        href = link_tag['href']
        next unless href && href.match?(/\/job\/|\/vaga\//i)

        titulo = link_tag.text.strip.gsub(/\s+/, ' ')
        next if titulo.empty?

        link_completo = href.start_with?('http') ? href : "https://remotar.com.br#{href}"

        vagas_encontradas << {
          titulo: titulo,
          link: link_completo,
          fonte: "Remotar"
        }
      end
    rescue => e
      puts "⚠️ Erro ao acessar o Remotar: #{e.message}"
    end

    vagas_encontradas.uniq { |v| v[:link] }
  end
end
