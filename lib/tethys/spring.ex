defprotocol Tethys.Spring do
  @spec flow(spring :: term, flow :: term) :: term
  def flow(spring, flow)
end