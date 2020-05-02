import introJs from "intro.js"

const intro = introJs()

intro.setOptions({
    showBullets: false,
    showProgress: true
})

if(!window.localStorage.getItem("onboarded")){
    intro.start()
}

intro.onexit(function() {
    window.localStorage.setItem("onboarded", "true")
})