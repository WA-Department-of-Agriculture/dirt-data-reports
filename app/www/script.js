function activateSteps(stepNumber) {
      // Loop through all steps and add the 'active' class to each step up to the clicked one
      for (let i = 1; i <= 5; i++) {
        let stepButton = document.getElementById('step' + i);
        let slide = document.getElementById('slide' + i);
        
        if (i <= stepNumber) {
          stepButton.classList.add('active');
        } else {
          stepButton.classList.remove('active');
        }

        // Show the corresponding slide and hide the others
        if (i === stepNumber) {
          slide.classList.add('active-slide');
        } else {
          slide.classList.remove('active-slide');
        }
      }
    }

function nextSlide(stepNumber) {
  activateSteps(stepNumber);
}

const getHref = function(link){

        // find all links
        const links = document.getElementsByTagName("a");

        // since it returns an object, iterate over each entries
        Object.entries(links).forEach( (elem, i) => {

                // match data-value attribute with input var
                if(elem[1].getAttribute("data-value") === link){

                        // if match, click link
                        elem[1].click()
                }
        });
}