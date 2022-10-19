class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def not_found(error)
    output = { message: "your query could not be completed", errors: [error.message] }
    render_json(output, :not_found)
  end

  def render_json(hash, status = :ok)
    render json: hash, status: status
  end
end
