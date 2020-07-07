<p align="center">
    <a href="https://outpost-staging.herokuapp.com/">
        <img src="https://github.com/wearefuturegov/outpost/blob/master/app/assets/images/outpost.png?raw=true" width="350px" />               
    </a>
</p>
  
<p align="center">
    <em>Service directories done right</em>         
</p>

---


# Acceptance Test Suite

The acceptance tests run with the following command
```
bundle exec cucumber
```

To run the acceptance tests in firefox, set the BROWSER environment variable and run
```
BROWSER=firefox bundle exec cucumber
```

To run the acceptance tests in chrome (via chromedriver),
 set the BROWSER environment variable and run
```
BROWSER=remote_chrome bundle exec cucumber
```
This requires https://chromedriver.chromium.org/ to be running locally 

By default, tests set to run with the `@javascript` flag will use selenium, with the default browser
of headless-firefox.

To continue running all rack tests with rack, but choose your `@javascript` browser, run the tests like the following:
```
 CAPYBARA_JAVASCRIPT_DRIVER=firefox bundle exec cucumber
```