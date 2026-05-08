require 'net/http'
require 'uri'
require 'dotenv/load'

class TelegramBot
  def self.enviar(mensagem)
    token = ENV['TELEGRAM_TOKEN']
    chat_id = ENV['TELEGRAM_CHAT_ID']

    if token.nil? || chat_id.nil?
      puts "⚠️ Credenciais do Telegram ausentes no .env."
      return
    end

    url = URI("https://api.telegram.org/bot#{token}/sendMessage")
    # Dispara a requisição POST para o Telegram
    Net::HTTP.post_form(url,
      'chat_id' => chat_id,
      'text' => mensagem,
      'parse_mode' => 'Markdown'
    )
  end
end
