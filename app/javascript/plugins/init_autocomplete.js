import places from 'places.js';

const initAutocomplete = () => {
  const addressInput = document.getElementById('flat_address');
  const cityInput = document.getElementById('search_query');
  if (addressInput) {
    places({ container: addressInput });
  }
  if (cityInput) {
    places({
      container: cityInput,
      language: 'en', // Receives results in German
      type: 'city', // Search only for cities names
    });
    // console.log("hello")
  }
};

export { initAutocomplete };
