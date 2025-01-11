document.addEventListener("DOMContentLoaded", () => {
    const overlay = document.getElementById("expense-details-overlay");
    const overlayContent = overlay.querySelector(".expense-details");
  
    document.querySelectorAll(".expense-link").forEach(link => {
      link.addEventListener("click", (event) => {
        event.preventDefault();
        const url = link.getAttribute("href");
  
        // Fetch the expense details via AJAX
        fetch(url, { headers: { "Accept": "text/javascript" } })
          .then(response => response.text())
          .then(data => {
            // Populate the overlay with fetched content
            overlayContent.innerHTML = data;
  
            // Show the overlay
            overlay.classList.remove("hidden");
          })
          .catch(error => {
            console.error("Error fetching expense details:", error);
          });
      });
    });
  
    // Close overlay
    document.getElementById("close-overlay").addEventListener("click", () => {
      overlay.classList.add("hidden");
      overlayContent.innerHTML = ""; // Clear content
    });
  });
  