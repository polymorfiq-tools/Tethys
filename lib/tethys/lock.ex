defprotocol Tethys.Lock do
  @spec entrance(lock :: term) :: term
  def entrance(dam)

  @spec exit(lock :: term) :: term
  def exit(dam)
end
