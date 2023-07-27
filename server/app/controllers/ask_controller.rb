require "openai"

class AskController < ApplicationController
    rescue_from ActionController::ParameterMissing do |exception|
        render json: { error: "Required parameter missing: #{exception.param}" }, status: :bad_request
    end

    def ask 
        question = params.require(:question)
        response = openai_client.completions(
            parameters: {
            model: "text-davinci-003",
            prompt: question,
            max_tokens: 2000
        })
        if !response.nil? && response.key?('choices') && response['choices'].is_a?(Array) && response['choices'].length > 0
            render json: { answer: response['choices'][0]['text'] }
            return
        end
        render json: { answer: 'No response.' }
    end

    def lucky
        render json: { answer: "Here's a super lucky answer." }
    end

    private
    def openai_client
        @openai_client ||= OpenAI::Client.new()
    end
end
