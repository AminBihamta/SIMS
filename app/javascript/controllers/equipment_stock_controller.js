import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "formContent", "select", "stockDisplay"]

  connect() {
    this.closeListener = this.close.bind(this)
    // Initialize stock display for pre-selected equipment
    if (this.hasSelectTarget && this.selectTarget.value) {
      this.updateStock({ target: this.selectTarget })
    }
  }

  updateStock(event) {
    const equipmentId = event.target.value;
    if (!this.hasStockDisplayTarget) return;

    if (equipmentId) {
      fetch(`/equipments/${equipmentId}/stock`)
        .then((response) => response.json())
        .then((data) => {
          this.stockDisplayTarget.innerText = `Stock Available: ${data.stock}`;
        })
        .catch(error => {
          console.error('Error fetching stock:', error);
          this.stockDisplayTarget.innerText = "Error fetching stock information";
        });
    } else {
      this.stockDisplayTarget.innerText = "Stock Available: 0";
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