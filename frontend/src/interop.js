class MarkdownRenderer extends HTMLElement {
  connectedCallback() {
    this.innerHTML = marked.parse(this.getAttribute("markdowndata"));
  }
  static get observedAttributes() {
    return ["markdowndata"];
  }
}
customElements.define("markdown-renderer", MarkdownRenderer);

export const flags = ({ env }) => {
  return {
    windowWidth: window.innerWidth,
    windowHeight: window.innerHeight,
  };
};
