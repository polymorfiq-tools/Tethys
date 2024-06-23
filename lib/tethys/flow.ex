defprotocol Tethys.Flow do
  @spec receive(flow :: term, data :: term) :: term
  def receive(flow, data)
end
