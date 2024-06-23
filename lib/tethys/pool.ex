defprotocol Tethys.Pool do
  @spec leak(pool :: term, recipient :: pid) :: term
  def leak(pool, recipient)

  @spec sip(pool :: term, recipient :: pid) :: term
  def sip(pool, recipient)

  @spec drain(pool :: term, recipient :: pid) :: term
  def drain(pool, recipient)
end