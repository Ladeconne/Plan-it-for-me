import { initLoader } from "./init_loader";

const selectButton = document.querySelector("#select-all-categories");
const checkBoxes = document.querySelectorAll("input[type=checkbox]");
const nextText = document.querySelector(".prompt.next");
const arrowBox = document.querySelector(".right-arrow");

const rightArrow = () =>
  '<button class="btn" type="submit" form="category-form"><i class="chevron fas fa-chevron-right" id="load-button"></i></button>';

const injectArrow = () => {
  nextText.classList.remove("invisible");
  arrowBox.innerHTML = rightArrow();
  setTimeout(initLoader, 200);
};
const removeArrow = () => {
  if (nextText.classList.contains("invisible")) return;
  nextText.classList.add("invisible");
  arrowBox.innerHTML = "";
};

const selectAll = () => {
  if (selectButton) {
    selectButton.addEventListener("click", () => {
      selectButton.classList.toggle("selected");

      selectButton.classList.contains("selected")
        ? injectArrow()
        : removeArrow();
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
