import "nodelist-foreach-polyfill";
import "polyfill-array-includes";
import "time-input-polyfill/auto";
import datasetPolyfill from "conglomerate-element-dataset";

datasetPolyfill();

// polyfill .remove()
if (!("remove" in Element.prototype)) {
  Element.prototype.remove = function () {
    if (this.parentNode) {
      this.parentNode.removeChild(this);
    }
  };
}

import tabs from "./packs/_tabs";
import collapsible from "./packs/_collapsible";
import filters from "./packs/_filters";
import snapshots from "./packs/_snapshots";
import maps from "./packs/_maps";
import repeater from "./packs/_repeater";
import labels from "./packs/_labels";
import localOffer from "./packs/_local-offer";
import regularSchedule from "./packs/_regular-schedule";
import openCloseAll from "./packs/_open-close-all";
import wordCount from "./packs/_word-count";
import helpTips from "./packs/_help-tips";
import bulkTaxonomiesActions from "./packs/_bulk-taxonomies-actions";
import warnUnsavedChanges from "./packs/_warn-unsaved-changes";
import showIfChecked from "./packs/_show-if-checked";
import choices from "./packs/_choices";
import customFields from "./packs/_custom-fields";
import fixAjaxForms from "./packs/_fix-ajax-forms";
import wysiwyg from "./packs/_wysiwyg";
import clearVisibleFromTo from "./packs/_clear-visible-from-to";
