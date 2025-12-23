import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs";
mermaid.initialize({
  startOnLoad: true,
  theme: "base", // Use base to override easier
  themeVariables: {
    fontFamily: "JetBrains Mono, monospace",
    primaryColor: "#0F172A", // Matches var(--surface)
    primaryTextColor: "#EAF0FF", // Matches var(--text)
    primaryBorderColor: "#7AA2FF", // Matches var(--accent)
    lineColor: "rgba(255,255,255,.12)",
    secondaryColor: "#0F172A",
    tertiaryColor: "#0A0F1C",
    background: "#0F172A",
  },
  flowchart: { curve: "basis" },
});

// ======== CONFIG (edit these) ========
const EMAIL = "karmacharya.sushov@gmail.com";
// Put your PDF in the same folder as this HTML OR use a hosted link.
const RESUME_URL = "./resume.pdf";
// ====================================

const toast = document.getElementById("toast");
const toastMsg = document.getElementById("toastMsg");
const copyEmailBtn = document.getElementById("copyEmailBtn");
const resumeNavBtn = document.getElementById("resumeNavBtn");

// Wire up resume nav button safely
if (resumeNavBtn) {
  resumeNavBtn.setAttribute("href", RESUME_URL);
  resumeNavBtn.addEventListener("click", (e) => {
    if (!RESUME_URL || RESUME_URL === "#") {
      e.preventDefault();
      showToast("Set RESUME_URL in JS config (bottom of file).");
    }
  });
}

copyEmailBtn?.addEventListener("click", () => copyEmail());

function showToast(msg) {
  toastMsg.textContent = msg;
  toast.classList.add("show");
  clearTimeout(showToast._t);
  showToast._t = setTimeout(() => toast.classList.remove("show"), 2200);
}
window.showToast = showToast;

async function copyEmail() {
  try {
    await navigator.clipboard.writeText(EMAIL);
    showToast("Email copied to clipboard.");
  } catch (e) {
    const tmp = document.createElement("textarea");
    tmp.value = EMAIL;
    document.body.appendChild(tmp);
    tmp.select();
    document.execCommand("copy");
    tmp.remove();
    showToast("Email copied.");
  }
}
window.copyEmail = copyEmail;

// Mobile Menu Toggle
function toggleMenu() {
  const links = document.getElementById("navLinks");
  links.classList.toggle("open");
}
window.toggleMenu = toggleMenu;
