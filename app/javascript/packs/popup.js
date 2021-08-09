const closeModal = () => {
  const btn = document.querySelector("#closeme")
  btn.addEventListener('click', () => {
    document.querySelector(".activity-popup").remove()
  })
  const background = document.querySelector(".activity-popup")
  background.addEventListener('click', (event) => {
    if (event.target === background){
      document.querySelector(".activity-popup").remove()
    }
  })
}
const createPopUp = (e) => {
  fetch(`/activities/${e.currentTarget.dataset.id}`, {
    headers: { "Accept": "application/json" }
  })
  .then(response => response.json())
  .then(data => {
    document.body.insertAdjacentHTML('afterbegin', data.modal)
    setTimeout(()=> {
      closeModal()
    }, 100)
  })
}
const popUpWindow = () =>  {
  const popUps = document.querySelectorAll('.view-activity')
  popUps.forEach(popUp => {
    popUp.addEventListener('click', createPopUp )
  })
}
export {popUpWindow}
