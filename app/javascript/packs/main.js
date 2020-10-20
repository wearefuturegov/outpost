
import "nodelist-foreach-polyfill"
import "polyfill-array-includes"
import "time-input-polyfill/auto"
import datasetPolyfill from "conglomerate-element-dataset"

datasetPolyfill()

// polyfill .remove()
if (!('remove' in Element.prototype)) {
  Element.prototype.remove = function() {
      if (this.parentNode) {
          this.parentNode.removeChild(this);
      }
  };
}

import tabs from "./tabs"
import collapsible from "./collapsible"
import filters from "./filters"
import snapshots from "./snapshots"
import maps from "./maps"
import repeater from "./repeater"
import labels from "./labels"
import localOffer from "./local-offer"
import regularSchedule from "./regular-schedule"
import openCloseAll from "./open-close-all"
import wordCount from "./word-count"
import helpTips from "./help-tips"
import bulkTaxonomiesActions from "./bulk-taxonomies-actions"
import warnUnsavedChanges from "./warn-unsaved-changes"
import showIfChecked from "./show-if-checked"
import choices from "./choices"
import customFields from "./_custom-fields"
import fixAjaxForms from "./_fix-ajax-forms"