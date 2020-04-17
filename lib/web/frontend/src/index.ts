import { initHilights } from "./code-hilighter.js";
import { oldHashRedirector } from "./old-hash-redirector.js";
import { renderTimeText } from "./response-timer.js";

function init() {
  renderTimeText();
  initHilights();
}

function initCheck(): boolean {
  if (document.readyState === "interactive" || document.readyState === "complete") {
    document.removeEventListener("readystatechange", initCheck);
    init();
    return true;
  } else {
    return false;
  }
}

// This can be run immediately as hash is available even if document is not yet loaded
oldHashRedirector();

if (!initCheck()) {
  document.addEventListener("readystatechange", initCheck);
}
