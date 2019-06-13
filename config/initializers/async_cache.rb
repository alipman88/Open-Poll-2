# Monkey-patch the Rails cache to allow for asynchronous cache refreshing

class ActiveSupport::Cache::Store
  def fetch_async key, **opts
    res = Rails.cache.read(key)

    if res.nil?
      # If cache entry unavailable, refresh synchronously
      puts "=== miss ==="
      res = [yield, Time.now]
      Rails.cache.write(key, res)
    elsif res[1] + (opts[:expires_in] || 1.year) < Time.now
      # If cache entry expired, bump & refresh asynchronously
      puts "=== refresh ==="
      Rails.cache.write(key, [res[0], res[1] + (opts[:race_condition_ttl] || 0)])

      Thread.new do
        Rails.cache.write(key, [yield, Time.now])
      end
    else
      # An up to date entry is present -- serve that
      puts "=== hit ==="
    end

    return res[0]
  end
end
