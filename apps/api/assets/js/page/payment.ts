import {StripePayment} from "../lib/stripe-payment";
import {loadStripe} from '@stripe/stripe-js';

let chain = window.onload;
let payment;
window.onload = async () => {
    if (chain) chain();
    let stripe = await loadStripe("pk_test_51LjmzAB7XccR5GE0LC7RlFVJmvTx9cOkzau4TkyLyX7R2aglT75JsrNxK2yEVGLrUOrHvBrBj9QVWWWpNg4COx3T00vkd0ITDf");
    payment = new StripePayment(stripe);
    payment.confirmation_url = "http://dev-select.jetzy.com:8080/account/payment";
    let secret = document.querySelector("#stripe_client_secret").value;
    payment.initialize(secret);
    payment.check_status();
}