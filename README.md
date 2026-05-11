# Vagas Hunter AI 🚀

Automação em **Ruby** para scraping e curadoria inteligente de vagas, desenhada para otimizar prospecção ativa de mercado.

## 🧠 O que o projeto faz?
O sistema atua como um headhunter autônomo na nuvem. Ele vasculha plataformas de emprego focando em oportunidades de **Estágio** e **Júnior** para **Ruby on Rails** e **Java/Spring Boot**. A aplicação extrai as descrições, aplica um filtro inicial rigoroso (bloqueando níveis Pleno/Sênior) e utiliza Inteligência Artificial para avaliar o *fit* técnico com o candidato. Matches de alto potencial (Score >= 60%) são enviados em tempo real para o celular via Telegram.

## 🛠️ Arquitetura e Tecnologias
* **Ruby & Nokogiri:** Web Scraping estruturado com Design Pattern para modularização de fontes (atualmente *Programathor* e *Remotar*).
* **Google Gemini API (2.5 Flash):** Motor de análise semântica configurado com prompts estritos de nivelamento e resiliência de rede (tratamento de *Rate Limits* 429 e 503).
* **Telegram API:** Notificações instantâneas e formatação Markdown via HTTP POST nativo.
* **GitHub Actions (CI/CD):** Pipeline de automação Serverless executando *Cron Jobs* diários (09:00 BRT) de forma 100% autônoma.
* **JSON State Management:** Banco de dados simples em arquivo `.json` com auto-commit feito pelo bot do GitHub, garantindo que vagas processadas ontem não gastem cota de API hoje.

## 🚀 Como Executar

### Opção 1: Deploy na Nuvem (Autônomo)
A forma recomendada. O script rodará sozinho todos os dias sem depender da sua máquina física.
1. Suba o repositório para o seu GitHub.
2. Vá em **Settings > Secrets and variables > Actions** e adicione as *Repository Secrets*: `GEMINI_API_KEY`, `TELEGRAM_TOKEN` e `TELEGRAM_CHAT_ID`.
3. O fluxo de trabalho `.github/workflows/scraper.yml` já está configurado para disparar o script diariamente às 09:00.

### Opção 2: Localmente (Dev Mode)
1. Clone o repositório.
2. Instale as dependências: `bundle install`.
3. Crie um arquivo `.env` na raiz com as variáveis: `GEMINI_API_KEY`, `TELEGRAM_TOKEN` e `TELEGRAM_CHAT_ID`.
4. Rode o orquestrador: `bundle exec ruby scraper.rb`.
