// https://github.com/turbolinks/turbolinks/issues/85#issuecomment-338784510

document.addEventListener("ajax:complete", event => {

    let xhr = event.detail[0]

    if ((xhr.getResponseHeader("Content-Type") || "").substring(0, 9) === "text/html") {
        let referrer = window.location.href

        let snapshot = Turbolinks.Snapshot.wrap(xhr.response)
        Turbolinks.controller.cache.put(referrer, snapshot)
        Turbolinks.visit(referrer, { action: 'restore' })
    }

}, false)