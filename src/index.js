exports.handler = (event, context, callback) => {
    console.log(event.triggerSource);
    console.log(event.request);

    let signupEvent = ${signup_event};
    let adminCreateUserEvent = ${admin_create_user_event};
    let resendCodeEvent = ${resend_code_event};
    let forgotPasswordEvent = ${forgot_password_event};
    let updateUserAttributeEvent = ${update_user_attribute_event};
    let verifyUserAttributeEvent = ${verify_user_attribute_event};
    let authenticationEvent = ${authentication_event};

    switch (event.triggerSource) {
        case "CustomMessage_SignUp":
            event.response = signupEvent;
            break;
        case "CustomMessage_AdminCreateUser":
            event.response = adminCreateUserEvent;
            break;
        case "CustomMessage_ResendCode":
            event.response = resendCodeEvent;
            break;
        case "CustomMessage_ForgotPassword":
            event.response = forgotPasswordEvent;
            break;
        case "CustomMessage_UpdateUserAttribute":
            event.response = updateUserAttributeEvent;
            break;
        case "CustomMessage_VerifyUserAttribute":
            event.response = verifyUserAttributeEvent;
            break;
        case "CustomMessage_Authentication":
            event.response = authenticationEvent;
            break;
    }

    let email = event.request.userAttributes.email;
    let username = event.request.usernameParameter;
    let code = event.request.codeParameter;
    let token = event.request.clientMetadata != null && event.request.clientMetadata.token != null ? event.request.clientMetadata.token : "";

    for (var property in event.response) {
        if (Object.prototype.hasOwnProperty.call(event.response, property) && event.response[property] != null) {
            event.response[property] = event.response[property]
                .replace("{email}", email)
                .replace("{username}", username)
                .replace("{token}", token)
                .replace("{code}", code);
        }
    }

    console.log(event.response);
    callback(null, event);
};
