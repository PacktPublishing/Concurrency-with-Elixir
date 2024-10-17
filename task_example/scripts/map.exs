urls = [
        "https://example.com/page1",
        "https://example.com/page2",
        "https://example.com/page3",
        "https://example.com/page4"
      ]

x = Enum.map(urls, fn url -> TaskExample.request(url) end)
IO.inspect(x)
