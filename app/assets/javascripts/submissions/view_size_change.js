var small = true;
window.onload = function(e){
  document.getElementById("submissionImage").onclick = function(e) {
    if (small) {
      e.target.setAttribute("style", "cursor: zoom-out;")
    } else {
      e.target.setAttribute("style", "max-width: 100%; max-height: 600px; cursor: zoom-in;");
    }
    small = !small;
  }
};
