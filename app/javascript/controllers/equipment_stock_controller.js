import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  updateStock(event) {
    const equipmentId = event.target.value;

    if (equipmentId) {
      fetch(`/equipments/${equipmentId}/stock`)
        .then((response) => response.json())
        .then((data) => {
          document.querySelector("#stock-availability").innerText = `Stock Available: ${data.stock}`;
        });
    } else {
      document.querySelector("#stock-availability").innerText = "Stock Available: 0";
    }
  }
}
