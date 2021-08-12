import { initLoader } from "./init_loader";

const nextText = document.querySelector(".prompt.next");
const arrowBox = document.querySelector(".right-arrow");

const checkedNumber = () =>
  document.querySelectorAll('input[type="checkbox"]:checked').length;

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

const categoryCounter = () => {
  const labels = document.querySelectorAll("#category-form label");
  labels.forEach((label) => {
    label.addEventListener("click", () => {
      const checkbox = document.querySelector(`#${label.dataset.target}`);
      checkbox.checked = !checkbox.checked;
      checkedNumber() >= 4 ? injectArrow() : removeArrow();
    });
  });
};

export { categoryCounter };
