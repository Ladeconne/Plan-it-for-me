import places from 'places.js';

const initAutocomplete = () => {
  const addressInput = document.getElementById('flat_address');
  const cityInput = document.getElementById('search_query');
  if (addressInput) {
    places({ container: addressInput });
  }
  if (cityInput) {
    places({ container: cityInput });
    // console.log("hello")
  }
};

export { initAutocomplete };
