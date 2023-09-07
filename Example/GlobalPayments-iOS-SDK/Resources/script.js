function initGlobalPayments(data) {

    // Configure account
    GlobalPayments.configure({
        accessToken: data['token'],
        env: "sandbox", // or "production" "dev"
        apiVersion: "2021-03-22",
        enableCardFingerPrinting: true,
        requireCardHolderName: true,
    });

    // Create Form
    const cardForm = GlobalPayments.creditCard.form("#credit-card", {
        style: "gp-default",
        labels: {
            "card-cvv": " Security Code",
            "card-expiration": "Expiry Date",
            "card-holder-name": "Cardholder Name",
            "card-number": "Card Number",
        },
        titles: {
            "card-cvv": "Card CVV Input",
            "card-expiration": "Card Expiration Input",
            "card-holder-name": "Card Holder Name Input",
            "card-number": "Card Number Input",
            "submit": "Form Submit Button Input",
        },
        placeholders: {
            "card-cvv": "•••",
            "card-expiration": "MM / YY",
            "card-holder-name": "Cardholder Name",
            "card-number": "•••• •••• •••• ••••",
        },
        values: {
            //values for each fields
        },
    });

    cardForm.ready((fields) => {
        console.log("Registration of all credit card fields occurred");
        //change submit button text
        fields['submit'].setText('Pay Now Text')
        cardForm.addStylesheet({
            '#secure-payment-field-wrapper': {
                'display': 'block !important'
            },
            /* Change Card Number Label */
            'div.credit-card-card-number, label': {
                'color': 'red'
            },
            /* Card number Field error messages*/
            /* Display error if card is not valid */
            '#secure-payment-field.card-number.invalid + .extra-div-1::before': {
                'content': '"The Card Number is not valid"',
                'color': 'red',
                'height': '1em',
                'min-height': '1em',
                'width': '100%'
            },
            /* Display error if card length is not reached*/
            '#secure-payment-field.card-number.possibly-valid.invalid + .extra-div-1::before': {
                'content': '"The Card Number is not valid"',
                'color': 'red',
                'height': '1em',
                'min-height': '1em',
                'width': '100%'
            },
            /* Display error if card used is Diners*/
            '#secure-payment-field.card-number.valid.card-type-diners + .extra-div-1::before': {
                'content': '"Cannot use Diners Card. Please enter another card"',
                'color': 'red',
                'height': '1em',
                'min-height': '1em',
                'width': '100%'
            },
            /* Display error if card used is Discover*/
            '#secure-payment-field.card-number.valid.card-type-discover + .extra-div-1::before': {
                'content': '"Cannot use Discover Card. Please enter another card"',
                'color': 'red',
                'height': '1em',
                'min-height': '1em',
                'width': '100%'
            },
            /* Display error if card used is JCB*/
            '#secure-payment-field.card-number.valid.card-type-jcb + .extra-div-1::before': {
                'content': '"Cannot use JCB Card. Please enter another card"',
                'color': 'red',
                'height': '1em',
                'min-height': '1em',
                'width': '100%'
            },
            /* Display error if card used is unknown*/
            '#secure-payment-field.card-number.possibly-valid.invalid.card-type-unknown + .extra-div-1::before': {
                'content': '"Cannot use unknown Card. Please enter another card"',
                'color': 'red',
                'height': '1em',
                'min-height': '1em',
                'width': '100%'
            },

            /* Expiry Date error messages*/
            /* Display error if expiry date is not valid*/
            '#secure-payment-field.card-expiration.possibly-valid.invalid + .extra-div-1::before': {
                'content': '"Please enter a valid month/year"',
                'color': 'red',
                'height': '1em',
                'min-height': '1em',
                'width': '100%'
            },
            /* Display error if expiry date is in past*/
            '#secure-payment-field.card-expiration.invalid + .extra-div-1::before': {
                'content': '"The Expiry Date is not valid"',
                'color': 'red',
                'height': '1em',
                'min-height': '1em',
                'width': '100%'
            },
            /* Security Code error messages*/
            /* Display error if security code is too short*/
            '#secure-payment-field.card-cvv.possibly-valid.invalid + .extra-div-1::before': {
                'content': '"Security Code is too short"',
                'color': 'red',
                'height': '1em',
                'min-height': '1em',
                'width': '100%'
            },
            /* Display error if security code too long for Visa*/
            '#secure-payment-field.card-cvv.invalid.card-type-visa + .extra-div-1::before': {
                'content': '"Security Code must be 3 digits"',
                'color': 'red',
                'height': '1em',
                'min-height': '1em',
                'width': '100%'
            },
            /* Display error if security code too long for MC*/
            '#secure-payment-field.card-cvv.invalid.card-type-mastercard + .extra-div-1::before': {
                'content': '"Security Code must be 3 digits"',
                'color': 'red',
                'height': '1em',
                'min-height': '1em',
                'width': '100%'
            },
            /* Display error if security code too short for Amex*/
            '#secure-payment-field.card-cvv.card-type-amex.possibly-valid.invalid + .extra-div-1::before': {
                'content': '"Security Code for Amex must be 4 digits"',
                'color': 'red',
                'height': '1em',
                'min-height': '1em',
                'width': '100%'
            },
            '#text': {
                'content': '"Pay Now"',
                'color': 'red',
            },
        });
    });

    cardForm.on("card-number", "register", (resp) => {
        console.log("Registration of Card Number occurred", resp);
    });
    cardForm.on("card-number-test", (resp) => {
        console.log("card-number-test", resp)
    });
    cardForm.on("card-number", "error", (resp) => {
        console.log("card-number error", resp)
    });
    cardForm.on("card-expiration-test", (resp) => {
        console.log("card-expiration-test", resp)
    });
    cardForm.on("card-cvv-test", (resp) => {
        console.log("card-cvv-test", resp)
    });
    cardForm.on("card-type", (resp) => {
        console.log("card-type", resp)
    });

    cardForm.on("submit", "click", () => {
        window.webkit.messageHandlers.onSubmitAction.postMessage("");
    });

    cardForm.on("token-success", async (resp) => {
        console.log("Token Success -> ", resp);
        const response = {"paymentReference": resp.paymentReference, "cardType": resp.details.cardType };
        window.webkit.messageHandlers.onTokenizedSuccess.postMessage(response);
    });

    cardForm.on("token-error", (resp) => {
        let message = resp['reasons'][0]['message']
        console.log(message);
        window.webkit.messageHandlers.onTokenError.postMessage(message);
    });
}
