// const goButton = document.querySelector('.fake')

const initLoader = () => {
  const goButton = document.querySelector("#load-button");
  const catBox = document.querySelector(".box");
  if (goButton && catBox) {
    goButton.addEventListener("click", () => {
      // console.log('hello')
      catBox.style.display = "flex";
    });
  }
};

export { initLoader };
