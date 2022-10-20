module EmptyObjectSerializer
  def hash_for_one_record
    @resource ? super : { data: {} }
  end
end