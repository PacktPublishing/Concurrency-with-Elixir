# In this example, none of the requests are completed because the calling process
# exits almost immediately without waiting on any of the tasks to complete.
# You do NOT see any output printed to the screen. This demonstrates a potential
# problem when dealing with non-awaited tasks.
#
# To run:
#
# mix run scripts/too_fast.exs

urls = [
  "https://example.com/page1",
  "https://example.com/page2",
  "https://example.com/page3",
  "https://example.com/page4"
]

Enum.each(urls, fn url -> Task.start(fn -> TaskExample.request(url) end) end)
