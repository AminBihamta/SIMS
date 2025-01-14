document.addEventListener('DOMContentLoaded', () => {
  const equipmentSelect = document.getElementById('equipment-select');
  const stockContainer = document.getElementById('stock-container');
  const stockAvailable = document.getElementById('stock-available');
  const searchInput = document.getElementById('search');

  // Function to filter equipment options based on search
  function filterEquipment(searchTerm) {
    const options = equipmentSelect.options;
    searchTerm = searchTerm.toLowerCase();

    for (let i = 0; i < options.length; i++) {
      const option = options[i];
      const text = option.text.toLowerCase();
      if (text.includes(searchTerm) || option.value === '') {
        option.style.display = '';
      } else {
        option.style.display = 'none';
      }
    }
  }

  // Function to fetch stock for the selected equipment
  async function updateStock() {
    const equipmentId = equipmentSelect.value;

    if (equipmentId) {
      try {
        // Fetch stock information for the selected equipment
        const response = await fetch(`/equipments/${equipmentId}/stock`);
        if (response.ok) {
          const data = await response.json();
          // Update the stock display
          stockAvailable.textContent = `Stock Available: ${data.stock}`;
          stockContainer.style.display = 'block';
        } else {
          stockAvailable.textContent = `Stock Available: 0`;
          stockContainer.style.display = 'block';
        }
      } catch (error) {
        console.error("Error fetching stock:", error);
        stockAvailable.textContent = `Error fetching stock`;
        stockContainer.style.display = 'block';
      }
    } else {
      // Hide the stock container if no equipment is selected
      stockContainer.style.display = 'none';
    }
  }

  // Add event listeners
  if (equipmentSelect) {
    equipmentSelect.addEventListener('change', updateStock);
  }

  if (searchInput) {
    searchInput.addEventListener('input', (e) => {
      filterEquipment(e.target.value);
    });
  }

  // Initialize stock display if equipment is pre-selected
  if (equipmentSelect && equipmentSelect.value) {
    updateStock();
  }
});