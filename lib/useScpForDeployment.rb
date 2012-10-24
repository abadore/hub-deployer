module UseScpForDeployment
  def self.included(base)
    base.send(:alias_method, :old_upload, :upload)
    base.send(:alias_method, :upload,     :new_upload)
  end

  def new_upload(from, to)
    old_upload(from, to, :via => :scp)
  end
end

