vinyl-ruby
=============

Ruby client for vinyl service

# Usage

```ruby
client = Vinyl::Client.new do |config|
	config.version = 1
	config.endpoint = "http://vinyl-internal.production.us-west2.twitch.tv"
end

# Create
vod = client.vods.create(from: ["user", 1], type: "follows", to: ["user", 2], data: { foo: "bar" })
# => Vinyl::Association

# Fetch
vod = client.vods.fetch(id:, user: nil)
p vod.data
# => { foo: "bar" }

# List and count
vods, total = client.vods.list(from: ["user", 1], type: "followed_by", sort: "desc", limit: 100, offset: 0)
```
