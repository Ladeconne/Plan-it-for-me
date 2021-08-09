
const goButton = document.querySelector('#load-button')
// const goButton = document.querySelector('.fake')
const catBox = document.querySelector('.box')

const initLoader = () => {
  if (goButton && catBox) {
    goButton.addEventListener("click", () => {
      // console.log('hello')
      catBox.style.display = 'flex'
    });

  }
}



export { initLoader };
