// Entry point for the build script in your package.json
import "./_polyfills";
import Turbolinks from "turbolinks";
import Rails from "@rails/ujs";
// libs
import "./modules/_tabs";
import "./modules/_collapsible";
import "./modules/_filters";
import "./modules/_snapshots";
import "./modules/_maps";
import "./modules/_repeater";
import "./modules/_labels";
import "./modules/_local-offer";
import "./modules/_regular-schedule";
import "./modules/_open-close-all";
import "./modules/_word-count";
import "./modules/_help-tips";
import "./modules/_bulk-taxonomies-actions";
import "./modules/_warn-unsaved-changes";
import "./modules/_show-if-checked";
import "./modules/_choices";
import "./modules/_custom-fields";
import "./modules/_fix-ajax-forms";
import "./modules/_wysiwyg";
import "./modules/_clear-visible-from-to";

// These were taken from the old main.js file
Rails.start();
Turbolinks.start();
// these were commented out in the original code
// require("@rails/activestorage").start()
// require("channels")
