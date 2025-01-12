document.addEventListener("DOMContentLoaded", () => {
  const superClubSelect = document.querySelector(
    "select[name='super_club_id']"
  );
  const subClubSelect = document.querySelector("select[name='sub_club_id']");

  superClubSelect.addEventListener("change", () => {
    const superClubId = superClubSelect.value;

    fetch(`/clubs/${superClubId}/sub_clubs`)
      .then((response) => response.json())
      .then((data) => {
        subClubSelect.innerHTML = '<option value="">Select Sub Club</option>';
        data.forEach((subClub) => {
          const option = document.createElement("option");
          option.value = subClub.Club_ID;
          option.textContent = subClub.Club_Name;
          subClubSelect.appendChild(option);
        });
      });
  });
});
