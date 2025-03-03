import redis

r = redis.StrictRedis(host="192.168.7.15", port=6379)
r.ping()
a = r.scan()
r.xadd("balls", {b"test": b"oog"})
print("done")