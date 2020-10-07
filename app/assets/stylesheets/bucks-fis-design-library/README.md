# bucks-fis-design-library

A basic sass library for Buckinghamshire Council.

Made for [Outpost](github.com/wearefuturegov/outpost).

## Using it

Make sure that the `node_modules` folder is included in your sass build, then import the parts you want.

Most of the styles depend on these dependencies:

```
@import "vars";
@import "mixins";
@import "globals";
```

It comes bundled with these optional vendor styles:

```
@import "vendor/tippy";
@import "vendor/choices";
@import "vendor/tagify";
@import "vendor/diff";
```

And utility layout classes:

```
@import "layout";
```

Pieces of a common page layout:

```
@import "header";
@import "beta-banner";
@import "nav";
@import "page-header";
@import "shortcut-nav";
@import "footer";
```

Optional components:

```
@import "go-back";
@import "buttons";
@import "forms";
@import "big-numbers";
@import "tags";
@import "task-list";
@import "poppables";
@import "user-circles";
@import "tables";
@import "collapsibles";
@import "help-tips";
@import "choices";
@import "pagination";
@import "maps";
@import "mini-search";
@import "alerts";
@import "notices";
@import "errors";
@import "tagify";
@import "repeaters";
@import "stepper";
@import "todo";
@import "notes";
@import "tabs";
@import "snapshots";
@import "big-list";
@import "confirmation";
@import "filters";
```