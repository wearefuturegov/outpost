(cat app.json || echo '{}') | jq -r '.environments.test.buildpacks[].url' >.buildpacks &&
  (test -s .buildpacks || rm .buildpacks)
