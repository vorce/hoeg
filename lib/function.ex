defmodule Hoeg.Function do
  @callback run(Hoeg.State.t()) :: Hoeg.State.t()
end
