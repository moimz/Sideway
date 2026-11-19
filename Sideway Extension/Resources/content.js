document.addEventListener('auxclick', (event) => {
    if (event.button !== 3 && event.button !== 4) return;

    event.preventDefault();
    event.stopImmediatePropagation();

    if (event.button === 3) {
        history.back();
    } else {
        history.forward();
    }
}, true);
