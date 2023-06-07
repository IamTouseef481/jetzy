

class Wizard {
    jquery: any;

    form_aliases = {
        'login': '#log-in-form',
        'signup': '#sign-up-form',
        'forgot-password': '#forgot-password-form'
    };

    form_page_aliases = {
        'login': {},
        'signup': {
            'pg1': '#sign-up-pg1',
            'pg2': '#sign-up-pg2',
        },
        'forgot-password': {
            'pg1': '#forgot-password-form-pg1',
            'pg2': '#forgot-password-form-pg2',
        }
    }

    signup = {
        page: 0,
    }
    forgot_password = {
        page: 0,
    }

    constructor(jq) {
        this.jquery = jq;
    }




    //----------------------------------------------------------
    // Bind controls
    //----------------------------------------------------------
    bind() {
        this.jquery('.show-sign-up-form').click((e) => this.show_signup_form(e));
        this.jquery('.show-login-form').click((e) => this.show_login_form(e));
        this.jquery('.show-forgot-password-form').click((e) => this.show_forgot_password_form(e));

        this.jquery('.sign-up-next').click((e) => this.signup_next(e));
        this.jquery('.sign-up-back').click((e) => this.signup_back(e));

        this.jquery('#sign-up-submit').click((e) => this.submit_signup(e));
        this.jquery('#login-submit').click((e) => this.submit_login(e));
        this.jquery('#forgot-password-submit').click((e) => this.submit_forgot_password(e));

        this.jquery('#open-sign-in').click((e) => this.open_sign_in(e));
        this.jquery('#open-sign-up').click((e) => this.open_sign_up(e));
    }

    open_sign_in(e) {
        this.jquery("#login-modal").removeClass('d-none');
        this.jquery("#initial-buttons").addClass('d-none');
        this.show_signup_form(e);
    }

    open_sign_up(e) {
        this.jquery("#login-modal").removeClass('d-none');
        this.jquery("#initial-buttons").addClass('d-none');
        this.show_login_form(e);
    }

    //----------------------------------------------------------
    // Form Submission
    //----------------------------------------------------------
    submit_login(e) {
        e.preventDefault();
        if (this.login_validate()) {
            let csrf = window.csrf;
            let email = this.jquery('#log-in-form input[name="user"]')[0].value;
            let password = this.jquery('#log-in-form input[name="password"]')[0].value;
            // Attempt Login.
            this.jquery.post('/api/login', {email: email, password: password, _csrf_token: csrf}).done((data) => {
                window.location.replace('/account');
            }).fail((xhr, status, error) => {
                if (xhr.responseJSON && xhr.responseJSON["message"]) {
                    this.set_login_flash(xhr.responseJSON.message);
                } else {
                    this.set_login_flash("Login Error: " + error);
                }
            });
        }
    }

    submit_signup(e) {
        e.preventDefault();
        if (this.signup_validate()) {
            // request
            let request = {
                _csrf_token: window.csrf,
                email: this.jquery('#sign-up-form input[name="user"]')[0].value,
                password: this.jquery('#sign-up-form input[name="password"]')[0].value,
                referral_code: this.jquery('#sign-up-form input[name="referral"]')[0].value,
                first_name: this.jquery('#sign-up-form input[name="first_name"]')[0].value,
                last_name: this.jquery('#sign-up-form input[name="last_name"]')[0].value,
                age: this.jquery('#sign-up-form input[name="age"]')[0].value
            }
            this.jquery.post('/api/sign-up', request).done((data) => {
                window.location.replace('/account');
            }).fail((xhr, status, error) => {
                if (xhr.responseJSON && xhr.responseJSON["message"]) {
                    this.set_signup_flash(xhr.responseJSON.message);
                } else {
                    this.set_signup_flash("Login Error: " + error);
                }
            });
        }
    }

    submit_forgot_password(e) {
        e.preventDefault();
        if (this.forgot_password_validate()) {

            if (this.forgot_password.page == 0) {
                // gather fields.
                let csrf = window.csrf;
                let email = this.jquery('#forgot-password-form input[name="user"]')[0].value;
                // Attempt Login.
                this.jquery.post('/api/forgot-password', {email: email, _csrf_token: csrf}).done((data) => {
                    this.set_forgot_password_flash("Check email for password rest link.");
                    this.forgot_password.page = 1;
                    this.set_active_page('forgot-password', "pg2");
                }).error((xhr, status, error) => {
                    if (xhr.responseJSON && xhr.responseJSON["message"]) {
                        this.set_forgot_password_flash(xhr.responseJSON.message);
                    } else {
                        this.set_forgot_password_flash("Login Error: " + error);
                    }
                });
            } else if (this.forgot_password.page == 1) {
                // gather fields.
                let csrf = window.csrf;
                let otp = this.jquery('#forgot-password-form input[name="code"]')[0].value;
                let email = this.jquery('#forgot-password-form input[name="user"]')[0].value;
                let password = this.jquery('#forgot-password-form input[name="password"]')[0].value;
                // Attempt Login.
                this.jquery.post('/api/reset-password', {email: email, password: password, otp: otp,  _csrf_token: csrf}).done((data) => {
                    window.location.replace('/account');
                }).error((xhr, status, error) => {
                    if (xhr.responseJSON && xhr.responseJSON["message"]) {
                        this.set_forgot_password_flash(xhr.responseJSON.message);
                    } else {
                        this.set_forgot_password_flash("Login Error: " + error);
                    }
                });
            }
        }
    }

    //----------------------------------------------------------
    // Update Flash Messages
    //----------------------------------------------------------
    set_login_flash(message) {
        this.jquery('#login-form-flash').removeClass("d-none");
        this.jquery('#login-form-flash').text(message);
    }

    clear_login_flash() {
        this.jquery('#login-form-flash').addClass("d-none");
        this.jquery('#login-form-flash').text("");
    }

    set_signup_flash(message) {
        this.jquery('#sign-up-form-flash').removeClass("d-none");
        this.jquery('#sign-up-form-flash').text(message);
    }

    clear_signup_flash() {
        this.jquery('#sign-up-form-flash').addClass("d-none");
        this.jquery('#sign-up-form-flash').text("");
    }

    set_forgot_password_flash(message) {
        this.jquery('#forgot-password-form-flash').removeClass("d-none");
        this.jquery('#forgot-password-form-flash').text(message);
    }

    clear_forgot_password_flash() {
        this.jquery('#forgot-password-form-flash').addClass("d-none");
        this.jquery('#forgot-password-form-flash').text("");
    }



    //----------------------------------------------------------
    // Validation
    //----------------------------------------------------------
    signup_validate() {
        let message = '';
        let response = true;
        switch (this.signup.page) {
            case 0:
                let email = this.jquery('#sign-up-form input[name="user"]')[0].value;
                let password = this.jquery('#sign-up-form input[name="password"]')[0].value;
                if (!email || !email.includes("@")) {
                    message += "Email field must contain a valid email address."
                    response = false;
                }
                if (!password || password.length <= 6) {
                    message += "Password field must be at least six characters." + password;
                    response = false;
                }
                break;
            case 1:
                let first_name = this.jquery('#sign-up-form input[name="first_name"]')[0].value;
                let last_name = this.jquery('#sign-up-form input[name="last_name"]')[0].value;
                let age = this.jquery('#sign-up-form input[name="age"]')[0].value;

                if (!first_name || first_name.length == 0) {
                    message += "First name must be provided."
                    response = false;
                }
                if (!last_name || last_name.length == 0) {
                    message += "Last name must be provided."
                    response = false;
                }
                if (!age || age.length == 0) {
                    message += "Age must be provided."
                    response = false;
                }
                break;
        }
        if (!response) {
            this.set_signup_flash(message);
        } else {
            this.clear_signup_flash();
        }
        return response;
    }

    login_validate(clear = true) {
        let message = '';
        let response = true;

        let email = this.jquery('#log-in-form input[name="user"]')[0].value;
        let password = this.jquery('#log-in-form input[name="password"]')[0].value;
        if (!email || !email.includes("@")) {
            message += "Email field must contain a valid email address."
            response = false;
        }
        if (!password || password.length <= 6) {
            message += "Password field must be at least six characters." + password;
            response = false;
        }
        if (!response) {
            this.set_login_flash(message);
        } else if (clear) {
            this.clear_login_flash();
        }
        return response;
    }

    forgot_password_validate() {
        let message = '';
        let response = true;

        if (this.forgot_password.page == 0) {
            let email = this.jquery('#forgot-password-form input[name="user"]')[0].value;
            if (!email || !email.includes("@")) {
                message += "Email field must contain a valid email address."
                response = false;
            }
        }
        if (this.forgot_password.page == 1) {
            let password = this.jquery('#forgot-password-form input[name="password"]')[0].value;
            let code = this.jquery('#forgot-password-form input[name="code"]')[0].value;
            if (!code) {
                message += "Please set the reset code provided to you via email."
                response = false;
            }
            if (!password || password.length <= 6) {
                message += "Password field must be at least six characters." + password;
                response = false;
            }
            if (!password || password.length <= 6) {
                message += "Password field must be at least six characters." + password;
                response = false;
            }
        }

        if (!response) {
            this.set_forgot_password_flash(message);
        } else {
            this.clear_forgot_password_flash();
        }
        return response;
    }

    //----------------------------------------------------------
    // Form Navigation
    //----------------------------------------------------------
    signup_next(e) {
        e.preventDefault();
        if (this.signup_validate()) {
            this.signup.page++;
            this.set_active_page('signup', this.form_pages()['signup'][this.signup.page]);
        }
    }
    signup_back(e) {
        e.preventDefault();
        this.clear_signup_flash();
        this.signup.page--;
        this.set_active_page('signup', this.form_pages()['signup'][this.signup.page]);
    }

    show_signup_form(e) {
        e.preventDefault();
        this.set_active_form('signup');
    }

    show_login_form(e) {
        e.preventDefault();
        this.set_active_form('login');
    }

    show_forgot_password_form(e) {
        e.preventDefault();
        this.set_active_form('forgot-password');
    }


    //----------------------------------------------------------
    // Helpers
    //----------------------------------------------------------
    set_active_form(form) {
        this.form_set().forEach((f) => {
            if (f == form) this.show_form(f);
            else this.hide_form(f);
        });
    }

    set_active_page(form, page) {
        this.form_pages()[form].forEach((p) => {
            if (p == page) this.show_form_page(form, p);
            else this.hide_form_page(form, p);
        });
    }

    form_set() {
        return ['login', 'signup', 'forgot-password'];
    }

    form_pages() {
        return {
            'login': [],
            'signup': ['pg1', 'pg2'],
            'forgot-password': ['pg1', 'pg2']
        }
    }

    show_form(form) {
        this.jquery(this.form_aliases[form]).removeClass('d-none');
    }
    hide_form(form) {
        this.jquery(this.form_aliases[form]).addClass('d-none');
    }


    show_form_page(form, page) {
        this.jquery(this.form_page_aliases[form][page]).removeClass('d-none');
    }
    hide_form_page(form, page) {
        this.jquery(this.form_page_aliases[form][page]).addClass('d-none');
    }
}


let chain = window.onload;
window.onload = async (e) => {
    if (chain) chain(e);
    let wizard = new Wizard(window.jQuery);
    wizard.bind();

    let $ = window.jQuery;

    //------------------------------
    // Maaz
    //------------------------------
    $('.search-toggle').click(function(){
        $('.search-wrapper').toggleClass('show');
    });

    //
    // $('.modal-toggle').click(function(){
    //     $('.modalBox').toggleClass('show');
    // })
    //
    // $('.modalBox').click(function(){
    //     $(this).removeClass('show');
    // });

    $('.spinner').click(function(){
        $(".theme-selector").toggleClass('show');
    });
    $('.light').click(function(){
        $('body').addClass('light-theme');
        $('body').removeClass('dark-theme');
    });
    $('.dark').click(function(){
        $('body').toggleClass('dark-theme');
        $('body').removeClass('light-theme');
    });

// smooth scroll
    $(".navbar .nav-link").on('click', function(event) {

        if (this.hash !== "") {

            event.preventDefault();

            var hash = this.hash;

            $('html, body').animate({
                scrollTop: $(hash).offset().top
            }, 700, function(){
                window.location.hash = hash;
            });
        }
    });
}