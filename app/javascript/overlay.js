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

    // Handle form submission with AJAX
    document.addEventListener("submit", (event) => {
        const form = event.target;
        if (form.id === "form") {
            event.preventDefault(); // Prevent default form submission

            const formData = new FormData(form);
            const submitUrl = form.action;

            fetch(submitUrl, {
                method: form.method,
                body: formData,
                headers: {
                    "X-Requested-With": "XMLHttpRequest",
                },
            })
                .then((response) => {
                    if (response.ok) {
                        return response.json(); // Parse JSON response for success
                    } else {
                        return response.text().then((html) => {
                            throw { html, status: response.status };
                        });
                    }
                })
                .then((data) => {
                    if (data.success) {
                        window.location.href = data.redirect_url; // Redirect on success
                    }
                })
                .catch((error) => {
                    if (error.status === 422) {
                        overlayFormContent.innerHTML = error.html; // Replace content with error-rendered form
                    } else {
                        console.error("Error submitting form:", error);
                    }
                });
        }
    });
});
