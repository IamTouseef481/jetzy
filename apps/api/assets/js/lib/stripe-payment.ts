
export class StripePayment {
    public stripe;
    public publisher_key;
    public confirmation_url;
    private form;
    private container;
    private appearance;
    private client_secret;

    constructor(stripe) {
        this.stripe = stripe;
    }

    async initialize(secret, form = null, container = null, appearance = null) {
        this.client_secret = secret;
        this.form = form || "#payment-form";
        this.container = container || "#payment-element";
        this.appearance = appearance || { theme: "stripe" };
        this.elements = this.stripe.elements({
            appearance: this.appearance,
            clientSecret: this.client_secret
        });
        this.payment_element = this.elements.create("payment");
        this.payment_element.mount(this.container);
        document.querySelector(this.form).addEventListener("submit", (e) => this.handle_submit(e));
    }

    async handle_submit(e) {
        e.preventDefault();
        this.set_loading(true);
        const {error} = await this.stripe.confirmPayment({
           elements: this.elements,
           confirmParams: {
               return_url: this.confirmation_url
           }
        });

        // This point will only be reached if there is an immediate error when
        // confirming the payment. Otherwise, your customer will be redirected to
        // your `return_url`. For some payment methods like iDEAL, your customer will
        // be redirected to an intermediate site first to authorize the payment, then
        // redirected to the `return_url`.
        this.error = error;
        if (error.type === "card_error" || error.type === "validation_error") {
            this.show_message(error.message);
        } else {
            this.show_message("An unexpected error occurred.");
        }
        this.set_loading(false);
    }

    async check_status() {
        const client_secret = new URLSearchParams(window.location.search).get("payment_intent_client_secret");
        if (!client_secret) {
            return;
        }

        console.log("Response Secret", client_secret, this.stripe.retrievePaymentIntent(client_secret));
        const { paymentIntent } = await this.stripe.retrievePaymentIntent(client_secret);
        console.log(paymentIntent);
        if (paymentIntent) {
            switch (paymentIntent.status) {
                case "succeeded":
                    this.show_message("Payment succeeded!");
                    break;
                case "processing":
                    this.show_message("Your payment is processing.");
                    break;
                case "requires_payment_method":
                    this.show_message("Your payment was not successful, please try again.");
                    break;
                default:
                    this.show_message("Something went wrong.");
                    break;
            }
        } else {
            this.show_message("Something went wrong.");
        }
    }

    show_message(message) {
        const message_container = document.querySelector("#payment-message");
        message_container.classList.remove("hidden");
        message_container.textContent = message;
        setTimeout(function() {
            message_container.classList.add("hidden");
            message_container.textContent = "";
        }, 50000);
    }
    set_loading(is_loading) {
        if (is_loading) {
            document.querySelector("#submit").disabled = true;
            document.querySelector("#spinner").classList.remove("hidden");
            document.querySelector("#button-text").classList.add("hidden");
        } else {
            document.querySelector("#submit").disabled = false;
            document.querySelector("#spinner").classList.add("hidden");
            document.querySelector("#button-text").classList.remove("hidden");
        }
    }
}