import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["overlay", "formContent"]

  connect() {
    this.closeListener = this.close.bind(this)
  }

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

  show(event) {
    event.preventDefault()
    const url = event.currentTarget.getAttribute("href")
    
    fetch(url)
      .then(response => response.text())
      .then(html => {
        document.getElementById("overlay-form-content").innerHTML = html
        document.getElementById("overlay").style.display = "block"
      })
      .catch(error => {
        console.error('Error loading form:', error)
      })
  }

  close() {
    document.getElementById("overlay").style.display = "none"
    document.getElementById("overlay-form-content").innerHTML = ""
  }

  disconnect() {
    if (this.closeListener) {
      document.removeEventListener('click', this.closeListener)
    }
  }
}