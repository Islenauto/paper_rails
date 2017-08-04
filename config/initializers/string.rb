class String
  def sub_Em
    NKF.nkf('-m0Z1 -W -w', self)
  end
end
