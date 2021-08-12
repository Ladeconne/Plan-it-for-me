import { initLoader } from "./init_loader";
import Typed from "typed.js";
const counter = document.querySelector("#counter");
const container = document.querySelector(".instructions");
const nextText = document.querySelector(".prompt.next");
const arrowBox = document.querySelector(".right-arrow");

const checkedNumber = () =>
  document.querySelectorAll('input[type="checkbox"]:checked').length;

const updateCounter = () => (counter.innerText = checkedNumber());

const rightArrow = () =>
  '<button class="btn" type="submit" form="activity-form"><i class="chevron fas fa-chevron-right" id="load-button"></i></button>';

const injectArrow = () => {
  nextText.classList.remove("d-none");
  arrowBox.innerHTML = rightArrow();
  setTimeout(initLoader, 200);
};
const removeArrow = () => {
  if (nextText.classList.contains("d-none")) return;
  nextText.classList.add("d-none");
  arrowBox.innerHTML = "";
};

const typeActivity = (checkbox) => {
  let type_cat_id = `#selected-activities-${checkbox.dataset.category}`;
  let type_id = `#typed_${checkbox.dataset.id}`;

  const destination = document.querySelector(type_cat_id);

  if (document.querySelector(type_id) === null) {
    destination.insertAdjacentHTML(
      "beforeend",
      `<li><span id="typed_${checkbox.dataset.id}"></span></li>`
    );
    new Typed(type_id, {
      strings: [checkbox.value],
      showCursor: false,
      typeSpeed: 30,
    });
  } else {
    new Typed(type_id, {
      strings: [checkbox.value, ""],
      showCursor: false,
      backSpeed: 30,
      onComplete: () => {
        document.querySelector(type_id).parentElement.remove();
      },
    });
  }
};

const activityCounter = () => {
  if (!container) return;
  const activityNumber = parseInt(container.dataset.max);

  const labels = document.querySelectorAll("#activity-form label");
  labels.forEach((label) => {
    label.addEventListener("click", (e) => {
      if (e.target.classList.contains("eyecon")) return;
      const checkbox = document.querySelector(`#${label.dataset.target}`);
      if (activityNumber === checkedNumber() && !checkbox.checked) return;

      checkbox.checked = !checkbox.checked;
      updateCounter();
      activityNumber === checkedNumber() ? injectArrow() : removeArrow();
      typeActivity(checkbox);
    });
  });
};

export { activityCounter };
