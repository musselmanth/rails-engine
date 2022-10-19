class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::ParameterMissing, with: :invalid_params

  private

  def not_found(exception)
    render_json(ErrorSerializer.format_errors([exception.message]), :not_found)
  end

  def invalid_params
    render_json(ErrorSerializer.format_errors(["params are missing or invalid"]), :bad_request)
  end

  def render_json(hash, status = :ok)
    render json: hash, status: status
  end
end
