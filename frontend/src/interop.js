import "./web-components/prism.js";
class MarkdownRenderer extends HTMLElement {
  constructor() {
    super();
  }

  connectedCallback() {
    this.renderMarkdown();
  }

  static get observedAttributes() {
    return ["markdowndata"];
  }

  attributeChangedCallback() {
    this.renderMarkdown();
  }

  renderMarkdown() {
    const data = this.getAttribute("markdowndata");
    const tokenizer = new marked.Tokenizer();
    const renderer = new marked.Renderer();

    tokenizer.code = (src) => {
      const match = src.match(
        /^```(\w+)?\n([\s\S]*?)\n```(\{\{execute\}\})?\s*\n/
      );
      if (match) {
        const language = match[1];
        const code = match[2];
        const isExecutable = match[3] === "{{execute}}";
        if (isExecutable) {
          // Render as a clickable block
          return {
            type: "code",
            raw: match[0],
            lang: "e-" + "shell", // Use lang field to store the isExecutable flag
            text: code,
          };
        }
      }
      return false; // Use the built-in tokenizer for anything else
    };

    // tokenizer.codespan = (src) => {
    //   const match = src.match(/^(`+)([^`]|[^`][\s\S]*?[^`])\1(?!`)/);
    //   if (match) {
    //     const code = match[2];
    //     const isExecutable = code.endsWith("{{execute}}");
    //     const cleanCode = isExecutable ? code.slice(0, -11) : code;
    //     return {
    //       type: "codespan",
    //       raw: match[0],
    //       text: cleanCode,
    //       isExecutable,
    //     };
    //   }
    //   return false;
    // };

    // Custom renderer for the code block
    renderer.code = (code, infostring, escaped) => {
      const checkE = infostring.split("-");
      let isExecutable = checkE.length == 2;
      const lang = ((isExecutable ? checkE[1] : infostring) || "").match(
        /\S*/
      )[0];

      function highlight(code, lang)  {
        const grammer = Prism.languages[lang];
        if (!grammer) {
          console.warn(`Unable to find prism highlight for '${lang}'`);
          return;
        }
        return Prism.highlight(code, grammer, lang);
      };
      const out = highlight(code, lang)
      if (out != null && out !== code) {
        escaped = true;
        code = out
      }


      code = code.replace(/\n$/, "") + "\n";

      const escapeHTML = (html) => {
        return html
          .replace(/&/g, "&amp;")
          .replace(/</g, "&lt;")
          .replace(/>/g, "&gt;")
          .replace(/"/g, "&quot;")
          .replace(/'/g, "&#39;");
      };

      if (isExecutable) {
        // Render as a clickable block
        return (
          '<pre class="hover:ring hover:cursor-pointer hover:ring-green-500"><code >' +
          (escaped ? code : escapeHTML(code, true)) +
          "</code></pre>\n"
        );
      } else if (!lang) {
        // Render as a normal code block without language
        return (
          "<pre><code>" +
          (escaped ? code : escapeHTML(code, true)) +
          "</code></pre>\n"
        );
      } else {
        // Render as a normal code block with language
        return (
          '<pre><code class="' +
          escapeHTML(lang) +
          '">' +
          (escaped ? code : escapeHTML(code, true)) +
          "</code></pre>\n"
        );
      }
    };

    // renderer.codespan = (code, isExecutable) => {
    //   if (isExecutable) {
    //     return `<code onclick="executeCode('${code.replace(
    //       /'/g,
    //       "\\'"
    //     )}')">${code}</code>`;
    //   } else {
    //     return `<code>${code}</code>`;
    //   }
    // };

    marked.setOptions({
      renderer: renderer,
      tokenizer: tokenizer,
      headerIds: false,
      mangle: false,
    });
    this.innerHTML = marked.parse(data);
    console.log(
      "----------------------------------------------------next-page-------------------------------------------------"
    );
  }
}

// Define the function that will be executed when the code block is clicked
window.executeCode = (code) => {
  console.log(`Executing code: ${code}`);
  // Here you can define what should be done with the code, e.g., run it, display it, etc.
};

customElements.define("markdown-renderer", MarkdownRenderer);

export const flags = ({ env }) => {
  return {
    windowWidth: window.innerWidth,
    windowHeight: window.innerHeight,
  };
};

export const onReady = ({ app, env }) => {};
