document.addEventListener("DOMContentLoaded", () => {
  const clubModal = document.getElementById("clubModal");
  const clubModalContent = document.getElementById("modalClubDetails");
  const editClubModal = document.getElementById("editClubModal");
  const editClubModalContent = document.getElementById("modalEditClub");
  const closeBtns = document.querySelectorAll(".modal .close");

  document.querySelectorAll(".club").forEach((club) => {
    club.addEventListener("click", () => {
      const clubId = club.getAttribute("data-club-id");
      fetch(`/clubs/${clubId}`)
        .then((response) => response.text())
        .then((html) => {
          clubModalContent.innerHTML = html;
          clubModal.style.display = "block";
        });
    });
  });

  document.querySelectorAll("[data-toggle='modal']").forEach((button) => {
    button.addEventListener("click", (event) => {
      event.preventDefault();
      const target = button.getAttribute("data-target");
      const url = button.getAttribute("href");
      fetch(url)
        .then((response) => response.text())
        .then((html) => {
          if (target === "#editClubModal") {
            editClubModalContent.innerHTML = html;
            editClubModal.style.display = "block";
          }
        });
    });
  });

  closeBtns.forEach((btn) => {
    btn.addEventListener("click", () => {
      clubModal.style.display = "none";
      editClubModal.style.display = "none";
    });
  });

  window.addEventListener("click", (event) => {
    if (event.target == clubModal) {
      clubModal.style.display = "none";
    }
    if (event.target == editClubModal) {
      editClubModal.style.display = "none";
    }
  });
});
