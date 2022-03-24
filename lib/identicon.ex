defmodule Identicon do
  def main(input) do
    input
    |> hashInput
    |> pickColor
    |> buildGrid
    |> ifEven
    |> pixelMap
    |> draw
    |> saveImage(input)

  end

  def hashInput(input) do
      hex = :crypto.hash(:md5, input)
      |> :binary.bin_to_list

      %Identicon.Image{hex: hex}
  end

  def pickColor(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
      #it may be written also as
      #%Identicon.Image{hex: hex_list} = image
      #[r, g, b | _tail] = hex_list

      %Identicon.Image{image | color: {r, g, b}}

  end

  def buildGrid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror/1)
      #Flatten makes, that list of list will be just a one list
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image{image | grid: grid }

  end

  def mirror(row) do
    [first, second | _tail] = row
    row ++ [second, first]
  end

  def ifEven(%Identicon.Image{grid: grid } = image) do
    grid = Enum.filter(grid, fn({code, _index}) ->
        rem(code, 2) == 0
    end
      )
      %Identicon.Image{image | grid: grid}
  end


  #EGD DRAWING

  def pixelMap(%Identicon.Image{grid: grid} = image) do
    pixelMap = Enum.map(grid, fn({_hexCode, index}) ->

      hor = rem(index, 5) * 50
      vert = div(index, 5) * 50

      topL = {hor, vert}
      bottomR = {hor + 50, vert + 50}

      {topL, bottomR}
  end
    )

    %Identicon.Image{image | pixelMap: pixelMap}

  end

  def draw(%Identicon.Image{color: color, pixelMap: pixelMap}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each(pixelMap, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end
      )
    :egd.render(image)
  end

  def saveImage(image, input) do
    File.write("#{input}.png", image)
  end

end
