require 'nokogiri'
require 'open-uri'

class VagasComScraper
  def self.extrair_vagas(headers)
    vagas = []
    # Buscando por Ruby. Você pode alterar a query depois para Java/Spring
    url = "https://www.vagas.com.br/vagas-de-ruby"

    begin
      html = URI.open(url, **headers).read
      doc = Nokogiri::HTML(html, nil, 'UTF-8')

      # O Vagas.com geralmente lista as oportunidades em elementos com a classe .vaga
      doc.css('li.vaga').each do |vaga_html|
        elemento_link = vaga_html.css('a.link-detalhes-vaga').first
        next unless elemento_link

        titulo = elemento_link.text.strip
        link_parcial = elemento_link['href']
        link_completo = "https://www.vagas.com.br#{link_parcial}"

        vagas << {
          titulo: titulo,
          link: link_completo,
          fonte: "Vagas.com"
        }
      end
    rescue => e
      puts "⚠️ **Erro no scraper Vagas.com:** #{e.message}"
    end

    vagas
  end
end
