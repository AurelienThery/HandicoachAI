# frozen_string_literal: true

class AiService
  class << self
    def chat(messages, user: nil)
      provider = determine_provider
      case provider
      when :ollama
        OllamaProvider.new.chat(messages, user: user)
      when :mistral
        MistralProvider.new.chat(messages, user: user)
      when :openai
        OpenaiProvider.new.chat(messages, user: user)
      else
        # Fallback to mock for development without API
        MockProvider.new.chat(messages, user: user)
      end
    rescue StandardError => e
      Rails.logger.error("AI Service Error: #{e.message}")
      { error: e.message, content: "Désolé, une erreur est survenue. Veuillez réessayer." }
    end

    private

    def determine_provider
      if ENV["OLLAMA_URL"].present?
        :ollama
      elsif ENV["MISTRAL_API_KEY"].present?
        :mistral
      elsif ENV["OPENAI_API_KEY"].present?
        :openai
      else
        :mock
      end
    end
  end

  # Base provider class
  class BaseProvider
    def system_prompt
      <<~PROMPT
        Tu es HandIaCoach, un assistant IA spécialisé dans l'accompagnement des personnes en situation de handicap (TSA, polyhandicap) et leurs familles.

        Ton rôle est de:
        - Aider à créer des routines visuelles personnalisées et structurées
        - Proposer des étapes claires, simples et adaptées
        - Encourager l'autonomie de manière bienveillante
        - Répondre aux questions sur les stratégies d'accompagnement
        - Collaborer avec les familles et les professionnels

        Utilise un langage simple, positif et encourageant. Propose des suggestions concrètes et visuelles quand c'est pertinent.
      PROMPT
    end

    def prepare_messages(messages, user: nil)
      prepared = [{ role: "system", content: system_prompt }]
      messages.each do |msg|
        prepared << { role: msg[:role] || msg["role"], content: msg[:content] || msg["content"] }
      end
      prepared
    end
  end

  # Ollama local provider (Mistral model)
  class OllamaProvider < BaseProvider
    def initialize
      @base_url = ENV.fetch("OLLAMA_URL", "http://localhost:11434")
      @model = ENV.fetch("OLLAMA_MODEL", "mistral")
    end

    def chat(messages, user: nil)
      prepared = prepare_messages(messages, user: user)

      conn = Faraday.new(url: @base_url) do |f|
        f.request :json
        f.response :json
        f.options.timeout = 120
      end

      response = conn.post("/api/chat") do |req|
        req.body = {
          model: @model,
          messages: prepared,
          stream: false
        }
      end

      if response.success?
        content = response.body.dig("message", "content")
        { content: content, provider: :ollama }
      else
        { error: "Ollama error", content: "Erreur de connexion au modèle local." }
      end
    end
  end

  # Mistral API provider
  class MistralProvider < BaseProvider
    def initialize
      @api_key = ENV["MISTRAL_API_KEY"]
      @base_url = "https://api.mistral.ai"
      @model = ENV.fetch("MISTRAL_MODEL", "mistral-small-latest")
    end

    def chat(messages, user: nil)
      prepared = prepare_messages(messages, user: user)

      conn = Faraday.new(url: @base_url) do |f|
        f.request :json
        f.response :json
        f.options.timeout = 60
        f.headers["Authorization"] = "Bearer #{@api_key}"
      end

      response = conn.post("/v1/chat/completions") do |req|
        req.body = {
          model: @model,
          messages: prepared,
          max_tokens: 1024
        }
      end

      if response.success?
        content = response.body.dig("choices", 0, "message", "content")
        { content: content, provider: :mistral }
      else
        { error: "Mistral API error", content: "Erreur de connexion à l'API Mistral." }
      end
    end
  end

  # OpenAI API provider
  class OpenaiProvider < BaseProvider
    def initialize
      @api_key = ENV["OPENAI_API_KEY"]
      @base_url = "https://api.openai.com"
      @model = ENV.fetch("OPENAI_MODEL", "gpt-3.5-turbo")
    end

    def chat(messages, user: nil)
      prepared = prepare_messages(messages, user: user)

      conn = Faraday.new(url: @base_url) do |f|
        f.request :json
        f.response :json
        f.options.timeout = 60
        f.headers["Authorization"] = "Bearer #{@api_key}"
      end

      response = conn.post("/v1/chat/completions") do |req|
        req.body = {
          model: @model,
          messages: prepared,
          max_tokens: 1024
        }
      end

      if response.success?
        content = response.body.dig("choices", 0, "message", "content")
        { content: content, provider: :openai }
      else
        { error: "OpenAI API error", content: "Erreur de connexion à l'API OpenAI." }
      end
    end
  end

  # Mock provider for development without AI
  class MockProvider < BaseProvider
    def chat(messages, user: nil)
      last_message = messages.last
      content = last_message[:content] || last_message["content"]

      response = if content.downcase.include?("routine")
                   generate_routine_response
                 elsif content.downcase.include?("bonjour") || content.downcase.include?("salut")
                   "Bonjour ! Je suis HandIaCoach, votre assistant pour créer des routines visuelles personnalisées. Comment puis-je vous aider aujourd'hui ?"
                 else
                   generate_general_response(content)
                 end

      { content: response, provider: :mock }
    end

    private

    def generate_routine_response
      <<~RESPONSE
        Je serais ravi de vous aider à créer une routine ! Voici quelques questions pour personnaliser cette routine :

        1. **Pour qui** est cette routine ? (enfant, adulte, âge approximatif)
        2. **Quel type** de routine souhaitez-vous ? (matin, soir, repas, sortie, etc.)
        3. **Niveau d'autonomie** actuel de la personne ?
        4. Avez-vous des **besoins spécifiques** à prendre en compte ?

        Une fois que j'aurai ces informations, je pourrai vous proposer une routine adaptée avec des étapes claires et visuelles. 🌟
      RESPONSE
    end

    def generate_general_response(content)
      <<~RESPONSE
        Je comprends votre question. En tant qu'assistant spécialisé dans l'accompagnement des personnes en situation de handicap, je peux vous aider à :

        - **Créer des routines** adaptées et personnalisées
        - **Structurer des activités** quotidiennes
        - **Proposer des stratégies** d'accompagnement

        Dites-moi comment je peux vous être utile aujourd'hui ! 💙
      RESPONSE
    end
  end
end
