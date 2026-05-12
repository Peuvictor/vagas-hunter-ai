# Vagas Hunter AI 🚀

Automação em **Ruby** para scraping e curadoria inteligente de vagas, desenhada para otimizar prospecção ativa de mercado focada em **Júnior** e **Estágio**.

## 🧠 O que o projeto faz?
O sistema atua como um headhunter pessoal. Ele vasculha plataformas de emprego focando em oportunidades para **Ruby on Rails** e **Java/Spring Boot**. A aplicação extrai as descrições, aplica um filtro inicial rigoroso (bloqueando níveis Pleno/Sênior) e utiliza Inteligência Artificial para avaliar o *fit* técnico com o candidato. Matches de alto potencial (Score >= 60%) são enviados em tempo real para o celular via Telegram.

## 🛠️ Arquitetura e Tecnologias
* **Ruby & Nokogiri:** Web Scraping estruturado com Design Pattern para modularização de fontes (*Programathor*, *Remotar* e *Vagas.com*).
* **Google Gemini API (2.5 Flash):** Motor de análise semântica configurado com prompts estritos de nivelamento e resiliência de rede.
* **Telegram API:** Notificações instantâneas e formatação Markdown via HTTP POST nativo.
* **Disfarce de Navegador (Anti-Bot Bypass):** Implementação de headers HTTP complexos simulando um Google Chrome real no Windows para evitar bloqueios **403 Forbidden** de firewalls corporativos.
* **JSON State Management:** Banco de dados simples em arquivo `.json` garantindo que vagas processadas no passado não gastem cota de API hoje.

## 🚀 Como Executar (Apenas Ambiente Local)
**Atenção:** Devido a bloqueios severos de IP em servidores de nuvem (Data Centers/GitHub Actions), este script foi otimizado para rodar sob um **IP Residencial** limpo, garantindo 100% de taxa de sucesso no acesso às plataformas.

### Passos:
1. Clone o repositório.
2. Instale as dependências: `bundle install`.
3. Crie um arquivo `.env` na raiz com as variáveis: `GEMINI_API_KEY`, `TELEGRAM_TOKEN` e `TELEGRAM_CHAT_ID`.
4. Rode o orquestrador no seu terminal: `bundle exec ruby scraper.rb`.
