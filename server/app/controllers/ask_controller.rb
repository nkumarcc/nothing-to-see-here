class AskController < ApplicationController
    rescue_from ActionController::ParameterMissing do |exception|
        render json: { error: "Required parameter missing: #{exception.param}" }, status: :bad_request
    end

    def ask 
        question = params.require(:question)
        render json: { answer: question.chars.first }
    end

    def lucky
        render json: { answer: 'Here\'s a super lucky answer.' }
    end

    private
    def ask_params
        params.require(:question)
    end
end
