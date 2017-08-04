# -*- coding: utf-8 -*-
class Array
  # 合計
  def sum
    reduce(:+)
  end

  # 平均
  def average
    return 0 if self.empty?
    sum.to_f / size
  end

  # 分散
  def variance
    return 0 if self.empty?
    a = average
    reduce(0.0) { |s, i| s + ((i - a)**2) } / size
  end

  # 要素の長さの合計
  def sum_length
    return unless all? { |e| e.kind_of?(String) }
    reduce(0) { |s, i| s += i.length }
  end

  # Character Per Word
  def cpw
    return unless all? { |e| e.kind_of?(String) }
    sum_length.to_f / size
  end
end
