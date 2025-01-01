// app/javascript/overlay.js
document.addEventListener("DOMContentLoaded", () => {
    const overlay = document.getElementById("overlay");
    const overlayFormContent = document.getElementById("overlay-form-content");
    const openOverlayLink = document.getElementById("open-overlay");
    const closeOverlayButton = document.getElementById("close-overlay");

    // Open overlay and load form dynamically
    if (openOverlayLink) {
        openOverlayLink.addEventListener("click", (e) => {
            e.preventDefault();
            fetch(openOverlayLink.href)
                .then((response) => response.text())
                .then((html) => {
                    overlayFormContent.innerHTML = html; // Load form into the placeholder
                    overlay.style.display = "block"; // Show the overlay
                    document.body.classList.add("overlay-active"); // Disable pointer events on body
                });
        });
    }

    // Close the overlay
    if (closeOverlayButton) {
        closeOverlayButton.addEventListener("click", () => {
            overlay.style.display = "none";
            overlayFormContent.innerHTML = ""; // Clear the form content
            document.body.classList.remove("overlay-active"); // Re-enable pointer events on body
        });
    }
});
