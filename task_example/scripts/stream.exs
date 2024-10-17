urls = [
        "https://example.com/page1",
        "https://example.com/page2",
        "https://example.com/page3",
        "https://example.com/page4"
      ]

x = urls
|> Stream.map(fn url -> TaskExample.request(url) end)
|> Enum.to_list()
IO.inspect(x)
