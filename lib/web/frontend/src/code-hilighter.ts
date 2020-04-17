import { PRISM_LANGUAGES_PATH, PRISM_PATH } from "./config.js";

const CLASS_PREFIX = "language-" as const;

const DEPENDENCIES: { [key: string]: readonly string[] } = {
  "javascript": ["clike"],
  "actionscript": ["javascript"],
  "arduino": ["cpp"],
  "aspnet": ["markup", "csharp"],
  "bison": ["c"],
  "c": ["clike"],
  "csharp": ["clike"],
  "cpp": ["c"],
  "coffeescript": ["javascript"],
  "crystal": ["ruby"],
  "css-extras": ["css"],
  "d": ["clike"],
  "dart": ["clike"],
  "django": ["markup-templating"],
  "ejs": ["javascript", "markup-templating"],
  "etlua": ["lua", "markup-templating"],
  "erb": ["ruby", "markup-templating"],
  "fsharp": ["clike"],
  "firestore-security-rules": ["clike"],
  "flow": ["javascript"],
  "ftl": ["markup-templating"],
  "glsl": ["clike"],
  "gml": ["clike"],
  "go": ["clike"],
  "groovy": ["clike"],
  "haml": ["ruby"],
  "handlebars": ["markup-templating"],
  "haxe": ["clike"],
  "java": ["clike"],
  "javadoc": ["markup", "java", "javadoclike"],
  "jolie": ["clike"],
  "jsdoc": ["javascript", "javadoclike"],
  "js-extras": ["javascript"],
  "js-templates": ["javascript"],
  "jsonp": ["json"],
  "json5": ["json"],
  "kotlin": ["clike"],
  "latte": ["clike", "markup-templating", "php"],
  "less": ["css"],
  "lilypond": ["scheme"],
  "markdown": ["markup"],
  "markup-templating": ["markup"],
  "n4js": ["javascript"],
  "nginx": ["clike"],
  "objectivec": ["c"],
  "opencl": ["c"],
  "parser": ["markup"],
  "php": ["clike", "markup-templating"],
  "phpdoc": ["php", "javadoclike"],
  "php-extras": ["php"],
  "plsql": ["sql"],
  "processing": ["clike"],
  "protobuf": ["clike"],
  "pug": ["markup", "javascript"],
  "qml": ["javascript"],
  "qore": ["clike"],
  "jsx": ["markup", "javascript"],
  "tsx": ["jsx", "typescript"],
  "reason": ["clike"],
  "ruby": ["clike"],
  "sass": ["css"],
  "scss": ["css"],
  "scala": ["java"],
  "shell-session": ["bash"],
  "smarty": ["markup-templating"],
  "solidity": ["clike"],
  "soy": ["markup-templating"],
  "sparql": ["turtle"],
  "sqf": ["clike"],
  "swift": ["clike"],
  "tap": ["yaml"],
  "textile": ["markup"],
  "tt2": ["clike", "markup-templating"],
  "twig": ["markup"],
  "typescript": ["javascript"],
  "t4-cs": ["t4-templating", "csharp"],
  "t4-vb": ["t4-templating", "visual-basic"],
  "vala": ["clike"],
  "vbnet": ["basic"],
  "velocity": ["markup"],
  "wiki": ["markup"],
  "xeora": ["markup"],
  "xquery": ["markup"],
} as const;

const ALIASES: { [key: string]: string } = {
  "html": "markup",
  "xml": "markup",
  "svg": "markup",
  "mathml": "markup",
  "js": "javascript",
  "g4": "antlr4",
  "adoc": "asciidoc",
  "shell": "bash",
  "shortcode": "bbcode",
  "rbnf": "bnf",
  "conc": "concurnas",
  "dotnet": "csharp",
  "cs": "csharp",
  "coffee": "coffeescript",
  "jinja2": "django",
  "dns-zone": "dns-zone-file",
  "dockerfile": "docker",
  "eta": "ejs",
  "excel-formula": "xlsx",
  "xls": "xlsx",
  "gml": "gamemakerlanguage",
  "hs": "haskell",
  "tex": "latex",
  "context": "latex",
  "ly": "lilypond",
  "emacs": "lisp",
  "elisp": "lisp",
  "emacs-lisp": "lisp",
  "md": "markdown",
  "moon": "moonscript",
  "n4jsd": "n4js",
  "hdl": "nand2tetris",
  "objectpascal": "pascal",
  "px": "pcaxis",
  "pq": "powerquery",
  "mscript": "powerquery",
  "py": "python",
  "robot": "robotframework",
  "rb": "ruby",
  "solution-file": "sln",
  "rq": "sparql",
  "trig": "turtle",
  "ts": "typescript",
  "t4-cs": "t4",
  "visual-basic": "vb",
  "xeoracube": "xeora",
  "yml": "yaml",
} as const;

const state: {
  filesLoaded: Set<string>,
  rootLoaded: boolean,
  languageEls: Map<string, Array<[HTMLElement, HTMLElement]>>,
} = {
  filesLoaded: new Set(),
  rootLoaded: false,
  languageEls: new Map(),
};

function getFilename(language: string) {
  if (ALIASES.hasOwnProperty(language)) {
    language = ALIASES[language];
  }

  return `${language}.min.js`;
}

function loadCSS() {
  const styleEl = document.createElement("link");
  styleEl.rel = "stylesheet";
  styleEl.type = "text/css";
  styleEl.href = `${PRISM_PATH}/prism.css`;

  document.getElementsByTagName("head")[0].appendChild(styleEl);
}

function loadJSFile(name: string, isLanguage: boolean) {
  const path = isLanguage ? PRISM_LANGUAGES_PATH : PRISM_PATH;
  return import(`${path}/${name}`);
}

async function loadMainJS() {
  // Prevent Prism from running on its own
  (window as any).Prism = { manual: true };

  await loadJSFile("prism.min.js", false);
}

async function loadLanguage(language: string) {
  const filename = getFilename(language);
  if (state.filesLoaded.has(filename)) {
    return;
  }

  if (!state.rootLoaded) {
    loadCSS();
    await loadMainJS();
    state.rootLoaded = true;
  }

  const depsPromises = [];
  for (const dep of DEPENDENCIES[language] || []) {
    depsPromises.push(loadLanguage(dep));
  }

  await Promise.all(depsPromises);
  await loadJSFile(filename, true);
  state.filesLoaded.add(filename);
}

async function hilightCode(code: HTMLElement, language: string) {
  await loadLanguage(language);
  (window as any).Prism.highlightElement(code);
}

function addLoadPrompt(pre: HTMLElement, code: HTMLElement, language: string) {
  const loadButton = document.createElement("button");
  loadButton.textContent = `Load syntax highlighting for ”${language}”`;

  loadButton.addEventListener("click", async () => {
    const elsForLanguage = state.languageEls.get(language) || [];
    for (const [codeEl, btn] of elsForLanguage) {
      btn.setAttribute("disabled", "disabled");
      btn.textContent = `Loading ”${language}”…`;
      await hilightCode(codeEl, language);
      btn.remove();
    }

    state.languageEls.delete(language);
  });

  pre.parentElement!.insertBefore(loadButton, pre);
  state.languageEls.set(
    language,
    (state.languageEls.get(language) || []).concat([[code, loadButton]]),
  );
}

export function initHilights() {
  const codeEls = document.querySelectorAll(`pre>code[class*='${CLASS_PREFIX}']`);
  codeEls.forEach(async (el) => {
    for (const klass of el.classList.values()) {
      if (klass.startsWith(CLASS_PREFIX) && klass !== CLASS_PREFIX) {
        const language = klass.substring(CLASS_PREFIX.length);
        addLoadPrompt(el.parentElement as HTMLElement, el as HTMLElement, language);
        break;
      }
    }
  });
}
