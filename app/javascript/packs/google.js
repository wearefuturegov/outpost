import { Loader, LoaderOptions } from "google-maps"

export const initialise = async () => {
    if(!window.google){
        const loader = new Loader(process.env.GOOGLE_CLIENT_KEY, {
            libraries: ["places"]
        })
        await loader.load()
    }
}