class Array
  def delete_duplicated_id
    self.each_with_index do |record, i|
      self.each_with_index do |tmp, j|
        next if i >= j
        if record.first == tmp.first
          self.delete_at(j)
        end
      end
    end
  end
end
