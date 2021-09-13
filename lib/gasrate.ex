defmodule Gasrate do
  @moduledoc """
  Documentation for Gasrate.
  """

  @doc """
  Fetch National Avg.

  ## Examples

      iex> Gasrate.fetch_national_avg
      {:ok, 2.273}

  """

  def fetch_national_avg do
    {_, response} = Gasrate.Http.state_gas_price_averages()

    html = response.body

    {:ok, html} = Floki.parse_document(html)

    [result] = Floki.find(html, "p.numb")

    {_, _, avg} = result

    avg = List.first(avg)

    avg = String.replace(avg, "$", "")

    avg = String.trim(avg)

    response = String.to_float(avg)

    {:ok, response}
  end

  @doc """
  Fetch Rates.

  ## Examples

      iex> Gasrate.fetch_avg_rates("AZ")
      %{diesel: 2.89, mid: 2.669, premium: 2.877, regular: 2.447}

  """

  def fetch_avg_rates(state) do
    {_, response} = Gasrate.Http.fetch_avg_rates(state)

    html = response.body

    {:ok, html} = Floki.parse_document(html)

    result = Floki.find(html, "table.table-mob")

    result = List.first(result)

    {_, _, avg} = result

    [_, body] = avg

    {_, _, res} = body

    [current, _, _, _, _] = res

    {_, _, rate_list} = current

    newlist = List.delete_at(rate_list, 0)

    rates =
      Enum.map(newlist, fn x ->
        {_, _, name_list} = x

        rate = List.first(name_list)

        rate = String.replace(rate, "$", "")

        rate = String.trim(rate)

        String.to_float(rate)
      end)

    rates = %{
      regular: Enum.at(rates, 0),
      mid: Enum.at(rates, 1),
      premium: Enum.at(rates, 2),
      diesel: Enum.at(rates, 3)
    }

    {:ok, rates}
  end

  @doc """
  Fetch Rates.

  ## Examples

      iex> Gasrate.fetch_avg_rates!("AZ")
      {:ok, %{diesel: 2.89, mid: 2.669, premium: 2.877, regular: 2.447}}

  """
  def fetch_avg_rates!(state) do
    rates = fetch_avg_rates(state)
    {_, rates} = rates
    rates
  end

  @doc """
  Fetch National Avg.

  ## Examples

      iex> Gasrate.fetch_national_avg!
      2.273

  """
  def fetch_national_avg!() do
    rates = fetch_national_avg()
    {_, rates} = rates
    rates
  end
end
