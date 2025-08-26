# Ofsted stub

Allows us to spin up a fake ofsted feed when developing Outpost.

The main repo for this project can be found here [ofsted-feed](https://github.com/wearefuturegov/ofsted-feed)

```
docker build -t ofsted-stub .
docker run -p 8000:8000 ofsted-stub
```
