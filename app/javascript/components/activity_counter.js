const counter = document.querySelector("#counter");
const activityCheckBoxes = document.querySelectorAll("input[type=checkbox]");
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
};
const removeArrow = () => {
  if (nextText.classList.contains("d-none")) return;
  nextText.classList.add("d-none");
  arrowBox.innerHTML = "";
};

const activityCounter = () => {
  if (!container) return;
  const activityNumber = parseInt(container.dataset.max);

  const labels = document.querySelectorAll("#activity-form label");
  labels.forEach((label) => {
    label.addEventListener("click", () => {
      const checkbox = document.querySelector(`#${label.dataset.target}`);
      if (activityNumber === checkedNumber() && !checkbox.checked) return;

      checkbox.checked = !checkbox.checked;
      updateCounter();
      // XXX
      activityNumber === checkedNumber() ? injectArrow() : removeArrow();
    });
  });
};

export { activityCounter };
