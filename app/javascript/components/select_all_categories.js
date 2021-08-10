const selectButton = document.querySelector("#select-all-categories");
const checkBoxes = document.querySelectorAll("input[type=checkbox]");

const selectAll = () => {
  if (selectButton) {
    selectButton.addEventListener("click", () => {
      selectButton.classList.toggle("selected");

      checkBoxes.forEach((checkbox) => {
        if (selectButton.classList.contains("selected")) {
          selectButton.querySelector("span").innerText = "Unselect";
          checkbox.checked = true;
        } else {
          selectButton.querySelector("span").innerText = "Select";
          checkbox.checked = false;
        }
      });
    });
  }
};

export { selectAll };
