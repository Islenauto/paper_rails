class Array
  def uniq_id
    id_list = []
    self.delete_if do |array|
      id = array.first
      if id_list.include?(id)
        true
      else id_list.push(id)
        false
      end
    end
  end
end
