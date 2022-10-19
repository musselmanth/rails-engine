class ErrorSerializer
  
  def self.format_errors(errors)
    {
      message: "your query could not be completed",
      errors: errors
    }
  end
  
end