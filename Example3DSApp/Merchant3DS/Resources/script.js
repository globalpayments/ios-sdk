function initGpLibrary(data) {
    GlobalPayments.configure({
        accessToken: data['token'],
        apiVersion: "2021-03-22",
        env: "sandbox" // or "production"
    });
    
    initCardForm()
}

function initCardForm() {
    const cardForm = GlobalPayments.creditCard.form("#credit-card", {style: "gp-default" });

    // method to notify that hosted fields have been initialized
    cardForm.ready(() => {
        console.log("Registration of all credit card fields occurred");
        //TODO: Add your successful message
    });

    // appending the token to the form as a hidden field and
    // submitting it to the server-side
    cardForm.on("token-success", (resp) => {
        // add payment token to form as a hidden input
        console.log("Token Success -> ", resp);
        const token = document.createElement("input");
        token.type = "hidden";
        token.name = "payment-reference";
        token.value = resp.paymentReference;
        const form = document.getElementById("payment-form");
        form.appendChild(token);
        form.submit();
        const response = {"paymentReference": resp.paymentReference, "cardType": resp.details.cardType };
        window.webkit.messageHandlers.onTokenizedSuccess.postMessage(response);
    });
    
    cardForm.on("click", (resp) => {
        console.log("SubmitClick");
        window.webkit.messageHandlers.onSubmitAction.postMessage("");
    });

    // add error handling if token generation is not successful
    cardForm.on("token-error", (resp) => {
        // TODO: Add your error handling
        let message = resp['reasons'][0]['message']
        console.log(message);
        window.webkit.messageHandlers.onTokenError.postMessage(message);
    });

    // field-level event handlers. example:
    cardForm.on("card-number", "register", () => {
        console.log("Registration of Card Number occurred");
    });
}
