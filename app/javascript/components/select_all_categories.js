const selectButton = document.querySelector("#select-all-categories");
const checkBoxes = document.querySelectorAll("input[type=checkbox]");

const selectAll = () => {
  if (selectButton) {
    selectButton.addEventListener("click", () => {
      checkBoxes.forEach((checkbox) => {
        if (checkbox.checked === true) {
          checkbox.checked = false;
        } else {
          checkbox.checked = true;
        }
      });
    });
  }
};

export { selectAll };
