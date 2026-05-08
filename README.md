# Vagas Hunter AI 🚀

Automação em **Ruby** para scraping e curadoria inteligente de vagas, desenhada para otimizar transições de carreira.

## 🧠 O que o projeto faz?
O sistema atua como um headhunter autônomo. Ele vasculha plataformas de emprego em busca de vagas (focando em **Ruby on Rails**, **Java/Spring Boot** e **Estágios**), extrai as descrições e utiliza Inteligência Artificial para avaliar o *fit* técnico com o perfil do candidato. Matches de alto potencial (Score > 60%) são enviados em tempo real para o celular via Telegram.

## 🛠️ Arquitetura e Tecnologias
* **Ruby & Nokogiri:** Web Scraping estruturado com Design Pattern (Strategy) para fácil adição de novos sites (atualmente *Programathor* e *Remotar*).
* **Google Gemini API (2.0 Flash):** Motor de análise semântica configurado com prompts rigorosos e tolerância a falhas (tratamento de *Rate Limits* 429 e 503).
* **Telegram API:** Notificações instantâneas via HTTP POST nativo.
* **JSON Local Storage:** Sistema de memória persistente para evitar reprocessamento de vagas já avaliadas, economizando cota de API.

## 🚀 Como rodar
1. Clone o repositório.
2. Rode `bundle install`.
3. Crie um arquivo `.env` com as variáveis: `GEMINI_API_KEY`, `TELEGRAM_TOKEN`, `TELEGRAM_CHAT_ID`.
4. Execute: `bundle exec ruby scraper.rb`.
